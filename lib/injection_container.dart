import 'package:get_it/get_it.dart';

import 'package:tmdb/core/logging/app_logger.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/core/storage/hive_storage.dart';
import 'package:tmdb/features/favourites/data/repositories/favourites_repository_impl.dart';
import 'package:tmdb/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:tmdb/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:tmdb/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_search_bloc/movie_search_bloc.dart';
import 'package:tmdb/features/people/data/datasources/person_remote_data_source.dart';
import 'package:tmdb/features/people/data/repositories/person_repository_impl.dart';
import 'package:tmdb/features/people/domain/repositories/person_repository.dart';
import 'package:tmdb/features/people/presentation/bloc/person_detail_bloc/person_detail_bloc.dart';
import 'package:tmdb/features/tv/data/datasources/tv_remote_data_source.dart';
import 'package:tmdb/features/tv/data/repositories/tv_repository_impl.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_detail_bloc/tv_detail_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_list_bloc/tv_list_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_search_bloc/tv_search_bloc.dart';

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

  // ── TV feature ─────────────────────────────────────────
  sl.registerLazySingleton(() => TvRemoteDataSource(sl()));
  sl.registerLazySingleton<TvRepository>(
    () => TvRepositoryImpl(sl(), logger: sl<AppLogger>()),
  );

  sl.registerFactory(() => TvListBloc(repository: sl()));
  sl.registerFactory(() => TvSearchBloc(repository: sl()));
  sl.registerFactory(() => TvDetailBloc(repository: sl()));

  // ── People feature ─────────────────────────────────────
  sl.registerLazySingleton(() => PersonRemoteDataSource(sl()));
  sl.registerLazySingleton<PersonRepository>(
    () => PersonRepositoryImpl(sl(), logger: sl<AppLogger>()),
  );

  sl.registerFactory(() => PersonDetailBloc(repository: sl()));

  // ── Favourites feature ─────────────────────────────────
  sl.registerLazySingleton<FavouritesRepository>(
    () => FavouritesRepositoryImpl(sl<HiveStorage>()),
  );
  sl.registerLazySingleton<FavouritesCubit>(() => FavouritesCubit(sl()));
}
