import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:tmdb/features/home/domain/repositories/trending_repository.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';
import 'package:tmdb/features/recommendations/domain/entities/recommendation_seed.dart';
import 'package:tmdb/features/recommendations/domain/repositories/recommendations_repository.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';

import 'home_event.dart';
import 'home_state.dart';

/// One saved title reduced to what the seeding logic needs.
typedef _SavedEntry = ({MediaType type, int id, DateTime savedAt});

/// Aggregates every editorial home rail and keeps the personalised "For You"
/// rail in sync with the user's favourites and watchlist.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required TrendingRepository trendingRepository,
    required MovieRepository movieRepository,
    required TvRepository tvRepository,
    required RecommendationsRepository recommendationsRepository,
    required FavouritesRepository favouritesRepository,
    required WatchlistRepository watchlistRepository,
  }) : _trending = trendingRepository,
       _movies = movieRepository,
       _tv = tvRepository,
       _recommendations = recommendationsRepository,
       _favourites = favouritesRepository,
       _watchlist = watchlistRepository,
       super(const HomeState()) {
    on<HomeStarted>((_, emit) => _load(emit, initial: true));
    on<HomeRefreshed>((_, emit) => _load(emit, initial: false));
    on<HomeForYouRefreshRequested>(_onForYouRefresh);

    // Keep For You live. `skip(1)` drops the snapshot each store replays on
    // subscribe (the first load already computes For You); only real changes
    // afterwards schedule a debounced recompute.
    _favSub = _favourites.watchAll().skip(1).listen((_) => _scheduleForYou());
    _watchSub = _watchlist.watchAll().skip(1).listen((_) => _scheduleForYou());

    add(const HomeStarted());
  }

  final TrendingRepository _trending;
  final MovieRepository _movies;
  final TvRepository _tv;
  final RecommendationsRepository _recommendations;
  final FavouritesRepository _favourites;
  final WatchlistRepository _watchlist;

  static const int _maxSeeds = 8;

  late final StreamSubscription<void> _favSub;
  late final StreamSubscription<void> _watchSub;
  Timer? _forYouDebounce;

  Future<void> _load(Emitter<HomeState> emit, {required bool initial}) async {
    if (initial) emit(state.copyWith(status: HomeStatus.loading));

    // Kick everything off concurrently, then await.
    final trendingF = _trending.getTrending();
    final nowF = _movies.getMovies(category: MovieCategory.nowPlaying);
    final topF = _movies.getMovies(category: MovieCategory.topRated);
    final upF = _movies.getMovies(category: MovieCategory.upcoming);
    final tvF = _tv.getTvShows(category: TvCategory.popular);
    final forYouF = _forYou();

    final trendingE = await trendingF;
    final nowE = await nowF;
    final topE = await topF;
    final upE = await upF;
    final tvE = await tvF;
    final forYouE = await forYouF;

    final anyCore =
        trendingE.isRight() ||
        nowE.isRight() ||
        topE.isRight() ||
        upE.isRight() ||
        tvE.isRight();

    if (!anyCore) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          message: _firstError([trendingE, nowE, topE, upE, tvE]),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: HomeStatus.loaded,
        message: '',
        trending: trendingE.getOrElse(() => const []),
        nowPlaying: nowE.fold((_) => const [], (p) => p.movies),
        topRated: topE.fold((_) => const [], (p) => p.movies),
        upcoming: upE.fold((_) => const [], (p) => p.movies),
        popularSeries: tvE.fold((_) => const [], (p) => p.shows),
        // Keep any previously-loaded For You if this fetch failed.
        forYou: forYouE.getOrElse(() => state.forYou),
      ),
    );
  }

  Future<void> _onForYouRefresh(
    HomeForYouRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state.status != HomeStatus.loaded) return;
    final result = await _forYou();
    result.fold((_) {}, (items) => emit(state.copyWith(forYou: items)));
  }

  /// Builds seeds from the most-recently saved titles (favourites + watchlist,
  /// newest first, deduped) and asks the recommendations repository for a
  /// ranked feed, excluding everything already saved.
  ResultFuture<List<PosterItem>> _forYou() {
    final entries = _savedEntries();
    if (entries.isEmpty) {
      return Future.value(const Right<Failure, List<PosterItem>>([]));
    }

    final excludeKeys = {for (final e in entries) '${e.type.name}:${e.id}'};
    final seeds = <RecommendationSeed>[];
    final seen = <String>{};
    for (final e in entries) {
      if (seen.add('${e.type.name}:${e.id}')) {
        seeds.add(RecommendationSeed(type: e.type, id: e.id));
      }
      if (seeds.length >= _maxSeeds) break;
    }

    return _recommendations.getForYou(seeds: seeds, excludeKeys: excludeKeys);
  }

  List<_SavedEntry> _savedEntries() {
    final entries = <_SavedEntry>[
      for (final f in _favourites.getAll())
        (type: f.mediaType, id: f.id, savedAt: f.savedAt),
      for (final w in _watchlist.getAll())
        (type: w.mediaType, id: w.id, savedAt: w.savedAt),
    ]..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return entries;
  }

  void _scheduleForYou() {
    _forYouDebounce?.cancel();
    _forYouDebounce = Timer(const Duration(milliseconds: 600), () {
      if (!isClosed) add(const HomeForYouRefreshRequested());
    });
  }

  String _firstError(List<Either<Failure, dynamic>> results) {
    for (final r in results) {
      final message = r.fold<String?>((f) => f.message, (_) => null);
      if (message != null) return message;
    }
    return 'Something went wrong.';
  }

  @override
  Future<void> close() async {
    _forYouDebounce?.cancel();
    await _favSub.cancel();
    await _watchSub.cancel();
    return super.close();
  }
}
