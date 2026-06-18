import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/exceptions.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:tmdb/features/recommendations/data/repositories/recommendations_repository_impl.dart';
import 'package:tmdb/features/recommendations/domain/entities/recommendation_seed.dart';
import 'package:tmdb/features/tv/data/datasources/tv_remote_data_source.dart';
import 'package:tmdb/shared/domain/poster_item.dart';

import '../../../../helpers/movie_fixtures.dart' show buildMovie, buildPaginated;
import '../../../../helpers/tv_fixtures.dart'
    show buildTvShow, buildPaginatedTv;

class _MockMovieRemote extends Mock implements MovieRemoteDataSource {}

class _MockTvRemote extends Mock implements TvRemoteDataSource {}

void main() {
  late _MockMovieRemote movieRemote;
  late _MockTvRemote tvRemote;
  late RecommendationsRepositoryImpl repository;

  setUp(() {
    movieRemote = _MockMovieRemote();
    tvRemote = _MockTvRemote();
    repository = RecommendationsRepositoryImpl(movieRemote, tvRemote);
  });

  List<int> idsOf(Either<Failure, List<PosterItem>> r) =>
      r.getOrElse(() => throw 'expected Right').map((e) => e.id).toList();

  test('empty seeds resolve to an empty list without any fetch', () async {
    final result = await repository.getForYou(seeds: const []);

    expect(result, const Right<Failure, List<PosterItem>>([]));
    verifyZeroInteractions(movieRemote);
    verifyZeroInteractions(tvRemote);
  });

  test('ranks by cross-seed frequency, then rating as tie-breaker', () async {
    // Two movie seeds. Title 100 is recommended by both (frequency 2) and must
    // outrank 200/300 (frequency 1) regardless of rating; 200 outranks 300 on
    // rating.
    when(() => movieRemote.getMovieRecommendations(1)).thenAnswer(
      (_) async => buildPaginated(
        movies: [buildMovie(id: 100, voteAverage: 5), buildMovie(id: 200, voteAverage: 9)],
      ),
    );
    when(() => movieRemote.getMovieRecommendations(2)).thenAnswer(
      (_) async => buildPaginated(
        movies: [buildMovie(id: 100, voteAverage: 5), buildMovie(id: 300, voteAverage: 7)],
      ),
    );

    final result = await repository.getForYou(
      seeds: const [
        RecommendationSeed(type: MediaType.movie, id: 1),
        RecommendationSeed(type: MediaType.movie, id: 2),
      ],
    );

    expect(idsOf(result), [100, 200, 300]);
  });

  test('excludes already-saved keys and the seeds themselves', () async {
    when(() => movieRemote.getMovieRecommendations(1)).thenAnswer(
      (_) async => buildPaginated(
        movies: [
          buildMovie(id: 1), // the seed itself — must be dropped
          buildMovie(id: 100),
          buildMovie(id: 200),
        ],
      ),
    );

    final result = await repository.getForYou(
      seeds: const [RecommendationSeed(type: MediaType.movie, id: 1)],
      excludeKeys: const {'movie:200'},
    );

    expect(idsOf(result), [100]);
  });

  test('mixes movie and TV recommendations from mixed seeds', () async {
    when(() => movieRemote.getMovieRecommendations(1)).thenAnswer(
      (_) async => buildPaginated(movies: [buildMovie(id: 100, voteAverage: 9)]),
    );
    when(() => tvRemote.getTvRecommendations(5)).thenAnswer(
      (_) async => buildPaginatedTv(shows: [buildTvShow(id: 400, voteAverage: 8)]),
    );

    final result = await repository.getForYou(
      seeds: const [
        RecommendationSeed(type: MediaType.movie, id: 1),
        RecommendationSeed(type: MediaType.tv, id: 5),
      ],
    );

    // Movie 100 (id collision space is per-type) and TV 400 both present.
    expect(idsOf(result), containsAll(<int>[100, 400]));
  });

  test('a movie id and a TV id that collide are kept as distinct titles', () async {
    when(() => movieRemote.getMovieRecommendations(1)).thenAnswer(
      (_) async => buildPaginated(movies: [buildMovie(id: 42)]),
    );
    when(() => tvRemote.getTvRecommendations(2)).thenAnswer(
      (_) async => buildPaginatedTv(shows: [buildTvShow(id: 42)]),
    );

    final result = await repository.getForYou(
      seeds: const [
        RecommendationSeed(type: MediaType.movie, id: 1),
        RecommendationSeed(type: MediaType.tv, id: 2),
      ],
    );

    // movie:42 and tv:42 are different keys → both survive.
    expect(idsOf(result), hasLength(2));
  });

  test('is best-effort: one failed seed is skipped, the rest still return',
      () async {
    when(() => movieRemote.getMovieRecommendations(1)).thenAnswer(
      (_) async => buildPaginated(movies: [buildMovie(id: 100)]),
    );
    when(() => movieRemote.getMovieRecommendations(2))
        .thenThrow(const NetworkException(message: 'offline'));

    final result = await repository.getForYou(
      seeds: const [
        RecommendationSeed(type: MediaType.movie, id: 1),
        RecommendationSeed(type: MediaType.movie, id: 2),
      ],
    );

    expect(idsOf(result), [100]);
  });

  test('returns a Failure only when every seed fetch fails', () async {
    when(() => movieRemote.getMovieRecommendations(any()))
        .thenThrow(const NetworkException(message: 'offline'));

    final result = await repository.getForYou(
      seeds: const [
        RecommendationSeed(type: MediaType.movie, id: 1),
        RecommendationSeed(type: MediaType.movie, id: 2),
      ],
    );

    expect(
      result,
      const Left<Failure, List<PosterItem>>(NetworkFailure(message: 'offline')),
    );
  });

  test('caps the result at limit', () async {
    when(() => movieRemote.getMovieRecommendations(1)).thenAnswer(
      (_) async => buildPaginated(
        movies: [
          buildMovie(id: 100, voteAverage: 9),
          buildMovie(id: 200, voteAverage: 8),
          buildMovie(id: 300, voteAverage: 7),
        ],
      ),
    );

    final result = await repository.getForYou(
      seeds: const [RecommendationSeed(type: MediaType.movie, id: 1)],
      limit: 2,
    );

    expect(idsOf(result), [100, 200]);
  });
}
