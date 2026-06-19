import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:tmdb/features/home/domain/repositories/trending_repository.dart';
import 'package:tmdb/features/home/presentation/bloc/home_bloc.dart';
import 'package:tmdb/features/home/presentation/bloc/home_state.dart';
import 'package:tmdb/features/movies/domain/entities/paginated_movies.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';
import 'package:tmdb/features/recommendations/domain/repositories/recommendations_repository.dart';
import 'package:tmdb/features/tv/domain/entities/paginated_tv_shows.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';

import '../../../../helpers/movie_fixtures.dart'
    show buildMovie, buildPaginated;
import '../../../../helpers/tv_fixtures.dart'
    show buildTvShow, buildPaginatedTv;

class _MockTrending extends Mock implements TrendingRepository {}

class _MockMovies extends Mock implements MovieRepository {}

class _MockTv extends Mock implements TvRepository {}

class _MockRecs extends Mock implements RecommendationsRepository {}

class _MockFav extends Mock implements FavouritesRepository {}

class _MockWatch extends Mock implements WatchlistRepository {}

void main() {
  late _MockTrending trending;
  late _MockMovies movies;
  late _MockTv tv;
  late _MockRecs recs;
  late _MockFav fav;
  late _MockWatch watch;

  Either<Failure, List<PosterItem>> trendingOk() =>
      Right([buildMovie(id: 1), buildTvShow(id: 2)]);
  Either<Failure, PaginatedMovies> movieOk(int id) =>
      Right(buildPaginated(movies: [buildMovie(id: id)]));
  Either<Failure, PaginatedTvShows> tvOk(int id) =>
      Right(buildPaginatedTv(shows: [buildTvShow(id: id)]));

  setUp(() {
    trending = _MockTrending();
    movies = _MockMovies();
    tv = _MockTv();
    recs = _MockRecs();
    fav = _MockFav();
    watch = _MockWatch();

    when(() => trending.getTrending()).thenAnswer((_) async => trendingOk());
    when(
      () => movies.getMovies(category: MovieCategory.nowPlaying),
    ).thenAnswer((_) async => movieOk(10));
    when(
      () => movies.getMovies(category: MovieCategory.topRated),
    ).thenAnswer((_) async => movieOk(11));
    when(
      () => movies.getMovies(category: MovieCategory.upcoming),
    ).thenAnswer((_) async => movieOk(12));
    when(
      () => tv.getTvShows(category: TvCategory.popular),
    ).thenAnswer((_) async => tvOk(20));

    // No saved titles → For You short-circuits without hitting the repo.
    when(() => fav.getAll()).thenReturn(const []);
    when(() => watch.getAll()).thenReturn(const []);
    when(() => fav.watchAll()).thenAnswer((_) => const Stream.empty());
    when(() => watch.watchAll()).thenAnswer((_) => const Stream.empty());
  });

  HomeBloc build() => HomeBloc(
    trendingRepository: trending,
    movieRepository: movies,
    tvRepository: tv,
    recommendationsRepository: recs,
    favouritesRepository: fav,
    watchlistRepository: watch,
  );

  blocTest<HomeBloc, HomeState>(
    'emits loading then loaded with every rail populated',
    build: build,
    wait: const Duration(milliseconds: 50),
    expect: () => [
      isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
      isA<HomeState>()
          .having((s) => s.status, 'status', HomeStatus.loaded)
          .having((s) => s.trending.map((e) => e.id), 'trending', [1, 2])
          .having((s) => s.nowPlaying.map((e) => e.id), 'nowPlaying', [10])
          .having((s) => s.topRated.map((e) => e.id), 'topRated', [11])
          .having((s) => s.upcoming.map((e) => e.id), 'upcoming', [12])
          .having((s) => s.popularSeries.map((e) => e.id), 'popularSeries', [
            20,
          ])
          .having((s) => s.forYou, 'forYou', isEmpty),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'is best-effort: a failed rail is empty but the page still loads',
    setUp: () => when(
      () => trending.getTrending(),
    ).thenAnswer((_) async => const Left(NetworkFailure(message: 'x'))),
    build: build,
    wait: const Duration(milliseconds: 50),
    expect: () => [
      isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
      isA<HomeState>()
          .having((s) => s.status, 'status', HomeStatus.loaded)
          .having((s) => s.trending, 'trending', isEmpty)
          .having((s) => s.nowPlaying.map((e) => e.id), 'nowPlaying', [10]),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'goes to error only when every core rail fails',
    setUp: () {
      const failure = NetworkFailure(message: 'offline');
      when(
        () => trending.getTrending(),
      ).thenAnswer((_) async => const Left<Failure, List<PosterItem>>(failure));
      for (final c in MovieCategory.values) {
        when(() => movies.getMovies(category: c)).thenAnswer(
          (_) async => const Left<Failure, PaginatedMovies>(failure),
        );
      }
      when(
        () => tv.getTvShows(category: TvCategory.popular),
      ).thenAnswer((_) async => const Left<Failure, PaginatedTvShows>(failure));
    },
    build: build,
    wait: const Duration(milliseconds: 50),
    expect: () => [
      isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
      isA<HomeState>()
          .having((s) => s.status, 'status', HomeStatus.error)
          .having((s) => s.message, 'message', 'offline'),
    ],
  );
}
