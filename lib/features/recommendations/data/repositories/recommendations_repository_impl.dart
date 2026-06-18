import 'package:dartz/dartz.dart';

import 'package:tmdb/core/error/exceptions.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/core/logging/app_logger.dart';
import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';
import 'package:tmdb/features/recommendations/domain/entities/recommendation_seed.dart';
import 'package:tmdb/features/recommendations/domain/repositories/recommendations_repository.dart';
import 'package:tmdb/features/tv/data/datasources/tv_remote_data_source.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/shared/domain/poster_item.dart';

class RecommendationsRepositoryImpl implements RecommendationsRepository {
  const RecommendationsRepositoryImpl(
    this._movieRemote,
    this._tvRemote, {
    AppLogger? logger,
  }) : _logger = logger;

  // Reuses the movie/TV feature data sources rather than duplicating the
  // `/recommendations` endpoint wiring.
  final MovieRemoteDataSource _movieRemote;
  final TvRemoteDataSource _tvRemote;
  final AppLogger? _logger;

  @override
  ResultFuture<List<PosterItem>> getForYou({
    required List<RecommendationSeed> seeds,
    Set<String> excludeKeys = const {},
    int limit = 20,
  }) async {
    if (seeds.isEmpty) return const Right([]);

    // Never recommend a seed back to the user who already saved it.
    final exclude = {...excludeKeys, for (final s in seeds) s.key};

    // Tally how many seeds recommend each title; a title surfaced by several
    // saved titles ranks above one surfaced by a single seed.
    final counts = <String, int>{};
    final byKey = <String, PosterItem>{};
    var failed = 0;
    Failure? lastFailure;

    for (final seed in seeds) {
      try {
        for (final item in await _fetchFor(seed)) {
          final key = _keyOf(item);
          if (exclude.contains(key)) continue;
          counts.update(key, (n) => n + 1, ifAbsent: () => 1);
          byKey.putIfAbsent(key, () => item);
        }
      } on UnauthorizedException catch (e, s) {
        failed++;
        lastFailure = _fail(
          ServerFailure(message: e.message, statusCode: 401),
          e,
          s,
        );
      } on ServerException catch (e, s) {
        failed++;
        lastFailure = _fail(
          ServerFailure(message: e.message, statusCode: e.statusCode),
          e,
          s,
        );
      } on NetworkException catch (e, s) {
        failed++;
        lastFailure = _fail(NetworkFailure(message: e.message), e, s);
      }
    }

    // Every fetch failed → surface the error instead of a silently empty rail.
    if (failed == seeds.length && lastFailure != null) {
      return Left(lastFailure);
    }

    final ranked = byKey.keys.toList()
      ..sort((a, b) {
        final byCount = counts[b]!.compareTo(counts[a]!);
        if (byCount != 0) return byCount;
        return _score(byKey[b]!).compareTo(_score(byKey[a]!));
      });

    return Right([for (final key in ranked.take(limit)) byKey[key]!]);
  }

  Future<List<PosterItem>> _fetchFor(RecommendationSeed seed) async {
    switch (seed.type) {
      case MediaType.movie:
        return (await _movieRemote.getMovieRecommendations(seed.id)).movies;
      case MediaType.tv:
        return (await _tvRemote.getTvRecommendations(seed.id)).shows;
    }
  }

  /// Tie-breaker within the same cross-seed frequency: prefer higher-rated
  /// titles, treating unrated ones (no votes) as the floor.
  double _score(PosterItem item) {
    if (item is Movie) return item.voteCount == 0 ? 0 : item.voteAverage;
    if (item is TvShow) return item.voteCount == 0 ? 0 : item.voteAverage;
    return 0;
  }

  String _keyOf(PosterItem item) =>
      item is TvShow ? 'tv:${item.id}' : 'movie:${item.id}';

  Failure _fail(Failure failure, Object error, StackTrace stackTrace) {
    _logger?.warning('$failure', error: error, stackTrace: stackTrace);
    return failure;
  }
}
