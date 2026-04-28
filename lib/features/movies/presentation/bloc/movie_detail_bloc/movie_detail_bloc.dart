import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/features/movies/data/repositories/movie_repository.dart';

import 'movie_detail_event.dart';
import 'movie_detail_state.dart';

class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  MovieDetailBloc({required MovieRepository repository})
    : _repository = repository,
      super(const MovieDetailInitial()) {
    on<MovieDetailFetched>(_onFetched);
  }

  final MovieRepository _repository;

  Future<void> _onFetched(
    MovieDetailFetched event,
    Emitter<MovieDetailState> emit,
  ) async {
    emit(const MovieDetailLoading());
    final result = await _repository.getMovieDetail(event.movieId);
    result.fold(
      (failure) => emit(MovieDetailError(message: failure.message)),
      (detail) => emit(MovieDetailLoaded(detail: detail)),
    );
  }
}
