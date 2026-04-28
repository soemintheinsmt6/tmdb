import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/features/movies/data/repositories/movie_repository.dart';

import 'movie_search_event.dart';
import 'movie_search_state.dart';

class MovieSearchBloc extends Bloc<MovieSearchEvent, MovieSearchState> {
  MovieSearchBloc({required MovieRepository repository})
    : _repository = repository,
      super(const MovieSearchIdle()) {
    on<MovieSearchQueryChanged>(_onQueryChanged);
    on<MovieSearchLoadMore>(_onLoadMore);
    on<MovieSearchCleared>(_onCleared);
  }

  final MovieRepository _repository;

  Future<void> _onQueryChanged(
    MovieSearchQueryChanged event,
    Emitter<MovieSearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const MovieSearchIdle());
      return;
    }

    emit(const MovieSearchLoading());
    final result = await _repository.searchMovies(query: query, page: 1);

    // Drop late results — only commit if the query is still the latest one
    // the bloc has been told about.
    if (state is! MovieSearchLoading) return;

    result.fold(
      (failure) => emit(MovieSearchError(message: failure.message)),
      (paginated) => emit(
        MovieSearchLoaded(
          query: query,
          movies: paginated.movies,
          page: paginated.page,
          totalPages: paginated.totalPages,
        ),
      ),
    );
  }

  Future<void> _onLoadMore(
    MovieSearchLoadMore event,
    Emitter<MovieSearchState> emit,
  ) async {
    final current = state;
    if (current is! MovieSearchLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    final result = await _repository.searchMovies(
      query: current.query,
      page: current.page + 1,
    );

    result.fold(
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (paginated) => emit(
        current.copyWith(
          movies: [...current.movies, ...paginated.movies],
          page: paginated.page,
          totalPages: paginated.totalPages,
          isLoadingMore: false,
        ),
      ),
    );
  }

  void _onCleared(MovieSearchCleared event, Emitter<MovieSearchState> emit) {
    emit(const MovieSearchIdle());
  }
}
