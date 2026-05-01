import 'package:get_it/get_it.dart';

import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/core/storage/object_box.dart';
import 'package:tmdb/features/favourites/data/repositories/favourites_repository.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:tmdb/features/movies/data/repositories/movie_repository.dart';
import 'package:tmdb/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_search_bloc/movie_search_bloc.dart';

final sl = GetIt.instance;

/// Call once before [runApp].
Future<void> init() async {
  // ── Core ────────────────────────────────────────────────
  sl.registerLazySingleton(() => ApiClient());

  final objectBox = await ObjectBox.create();
  sl.registerSingleton<ObjectBox>(objectBox);

  // ── Movies feature ─────────────────────────────────────
  // Repositories
  sl.registerLazySingleton<MovieRepository>(() => MovieRepositoryImpl(sl()));

  // BLoCs
  sl.registerFactory(() => MovieListBloc(repository: sl()));
  sl.registerFactory(() => MovieSearchBloc(repository: sl()));
  sl.registerFactory(() => MovieDetailBloc(repository: sl()));

  // ── Favourites feature ─────────────────────────────────
  sl.registerLazySingleton<FavouritesRepository>(
    () => FavouritesRepository(sl<ObjectBox>()),
  );
  sl.registerLazySingleton<FavouritesCubit>(() => FavouritesCubit(sl()));
}
