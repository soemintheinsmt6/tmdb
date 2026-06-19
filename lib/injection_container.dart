import 'package:get_it/get_it.dart';

import 'package:tmdb/core/logging/app_logger.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/core/storage/hive_storage.dart';
import 'package:tmdb/features/discover/data/datasources/discover_remote_data_source.dart';
import 'package:tmdb/features/discover/data/repositories/discover_repository_impl.dart';
import 'package:tmdb/features/discover/domain/repositories/discover_repository.dart';
import 'package:tmdb/features/discover/presentation/bloc/discover_bloc.dart';
import 'package:tmdb/features/favourites/data/repositories/favourites_repository_impl.dart';
import 'package:tmdb/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:tmdb/features/home/data/datasources/trending_remote_data_source.dart';
import 'package:tmdb/features/home/data/repositories/trending_repository_impl.dart';
import 'package:tmdb/features/home/domain/repositories/trending_repository.dart';
import 'package:tmdb/features/home/presentation/bloc/home_bloc.dart';
import 'package:tmdb/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:tmdb/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';
import 'package:tmdb/features/movies/presentation/bloc/collection_bloc/collection_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_search_bloc/movie_search_bloc.dart';
import 'package:tmdb/features/people/data/datasources/person_remote_data_source.dart';
import 'package:tmdb/features/people/data/repositories/person_repository_impl.dart';
import 'package:tmdb/features/people/domain/repositories/person_repository.dart';
import 'package:tmdb/features/people/presentation/bloc/person_detail_bloc/person_detail_bloc.dart';
import 'package:tmdb/features/recommendations/data/repositories/recommendations_repository_impl.dart';
import 'package:tmdb/features/recommendations/domain/repositories/recommendations_repository.dart';
import 'package:tmdb/features/search/data/datasources/search_remote_data_source.dart';
import 'package:tmdb/features/search/data/repositories/search_repository_impl.dart';
import 'package:tmdb/features/search/domain/repositories/search_repository.dart';
import 'package:tmdb/features/search/presentation/bloc/search_bloc/search_bloc.dart';
import 'package:tmdb/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:tmdb/features/settings/domain/repositories/settings_repository.dart';
import 'package:tmdb/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:tmdb/features/tv/data/datasources/tv_remote_data_source.dart';
import 'package:tmdb/features/tv/data/repositories/tv_repository_impl.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/features/tv/presentation/bloc/season_detail_bloc/season_detail_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_detail_bloc/tv_detail_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_feed_bloc/tv_feed_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_list_bloc/tv_list_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_search_bloc/tv_search_bloc.dart';
import 'package:tmdb/features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'package:tmdb/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:tmdb/features/watchlist/presentation/cubit/watchlist_cubit.dart';

final sl = GetIt.instance;

/// Call once before [runApp].
Future<void> init() async {
  // ── Core ────────────────────────────────────────────────
  sl.registerLazySingleton<AppLogger>(() => const ConsoleLogger());
  sl.registerLazySingleton(() => ApiClient(logger: sl<AppLogger>()));

  final hiveStorage = await HiveStorage.create();
  sl.registerSingleton<HiveStorage>(hiveStorage);

  // ── Movies feature ─────────────────────────────────────
  sl.registerLazySingleton(() => MovieRemoteDataSource(sl()));
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(sl(), logger: sl<AppLogger>()),
  );

  sl.registerFactory(() => MovieListBloc(repository: sl()));
  sl.registerFactory(() => MovieSearchBloc(repository: sl()));
  sl.registerFactory(() => MovieDetailBloc(repository: sl()));
  sl.registerFactory(() => CollectionBloc(repository: sl()));

  // ── TV feature ─────────────────────────────────────────
  sl.registerLazySingleton(() => TvRemoteDataSource(sl()));
  sl.registerLazySingleton<TvRepository>(
    () => TvRepositoryImpl(sl(), logger: sl<AppLogger>()),
  );

  sl.registerFactory(() => TvListBloc(repository: sl()));
  sl.registerFactory(() => TvSearchBloc(repository: sl()));
  sl.registerFactory(() => TvDetailBloc(repository: sl()));
  sl.registerFactory(() => SeasonDetailBloc(repository: sl()));
  sl.registerFactory(
    () => TvFeedBloc(tvRepository: sl(), trendingRepository: sl()),
  );

  // ── People feature ─────────────────────────────────────
  sl.registerLazySingleton(() => PersonRemoteDataSource(sl()));
  sl.registerLazySingleton<PersonRepository>(
    () => PersonRepositoryImpl(sl(), logger: sl<AppLogger>()),
  );

  sl.registerFactory(() => PersonDetailBloc(repository: sl()));

  // ── Search feature ─────────────────────────────────────
  sl.registerLazySingleton(() => SearchRemoteDataSource(sl()));
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(sl(), logger: sl<AppLogger>()),
  );

  sl.registerFactory(() => SearchBloc(repository: sl()));

  // ── Discover feature ───────────────────────────────────
  sl.registerLazySingleton(() => DiscoverRemoteDataSource(sl()));
  sl.registerLazySingleton<DiscoverRepository>(
    () => DiscoverRepositoryImpl(sl(), logger: sl<AppLogger>()),
  );

  sl.registerFactory(() => DiscoverBloc(repository: sl()));

  // ── Home / Trending feature ────────────────────────────
  sl.registerLazySingleton(() => TrendingRemoteDataSource(sl()));
  sl.registerLazySingleton<TrendingRepository>(
    () => TrendingRepositoryImpl(sl(), logger: sl<AppLogger>()),
  );

  // ── Recommendations feature ────────────────────────────
  sl.registerLazySingleton<RecommendationsRepository>(
    () => RecommendationsRepositoryImpl(sl(), sl(), logger: sl<AppLogger>()),
  );

  // ── Home feature (aggregates the above) ────────────────
  sl.registerFactory(
    () => HomeBloc(
      trendingRepository: sl(),
      movieRepository: sl(),
      tvRepository: sl(),
      recommendationsRepository: sl(),
      favouritesRepository: sl(),
      watchlistRepository: sl(),
    ),
  );

  // ── Favourites feature ─────────────────────────────────
  sl.registerLazySingleton<FavouritesRepository>(
    () => FavouritesRepositoryImpl(sl<HiveStorage>()),
  );
  sl.registerLazySingleton<FavouritesCubit>(() => FavouritesCubit(sl()));

  // ── Watchlist feature ──────────────────────────────────
  sl.registerLazySingleton<WatchlistRepository>(
    () => WatchlistRepositoryImpl(sl<HiveStorage>()),
  );
  sl.registerLazySingleton<WatchlistCubit>(() => WatchlistCubit(sl()));

  // ── Settings feature ───────────────────────────────────
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl<HiveStorage>()),
  );
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl()));
}
