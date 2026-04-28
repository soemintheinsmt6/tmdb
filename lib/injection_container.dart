import 'package:get_it/get_it.dart';

import 'package:tmdb/core/network/api_client.dart';
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

  // ── Movies feature ─────────────────────────────────────
  // Repositories
  sl.registerLazySingleton<MovieRepository>(() => MovieRepositoryImpl(sl()));

  // BLoCs
  sl.registerFactory(() => MovieListBloc(repository: sl()));
  sl.registerFactory(() => MovieSearchBloc(repository: sl()));
  sl.registerFactory(() => MovieDetailBloc(repository: sl()));
}
