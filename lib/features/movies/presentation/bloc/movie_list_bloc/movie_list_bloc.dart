import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/features/movies/data/repositories/movie_repository.dart';

import 'movie_list_event.dart';
import 'movie_list_state.dart';

class MovieListBloc extends Bloc<MovieListEvent, MovieListState> {
  MovieListBloc({
    required MovieRepository repository,
    MovieCategory initialCategory = MovieCategory.popular,
  }) : _repository = repository,
       super(MovieListInitial(category: initialCategory)) {
    on<MovieListCategoryChanged>(_onCategoryChanged);
    on<MovieListLoadMore>(_onLoadMore);
    on<MovieListRefreshed>(_onRefreshed);

    add(MovieListCategoryChanged(initialCategory));
  }

  final MovieRepository _repository;

  Future<void> _onCategoryChanged(
    MovieListCategoryChanged event,
    Emitter<MovieListState> emit,
  ) async {
    emit(MovieListLoading(category: event.category));
    final result = await _repository.getMovies(category: event.category, page: 1);
    result.fold(
      (failure) => emit(
        MovieListError(category: event.category, message: failure.message),
      ),
      (paginated) => emit(
        MovieListLoaded(
          category: event.category,
          movies: paginated.movies,
          page: paginated.page,
          totalPages: paginated.totalPages,
        ),
      ),
    );
  }

  Future<void> _onLoadMore(
    MovieListLoadMore event,
    Emitter<MovieListState> emit,
  ) async {
    final current = state;
    if (current is! MovieListLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    final result = await _repository.getMovies(
      category: current.category,
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

  Future<void> _onRefreshed(
    MovieListRefreshed event,
    Emitter<MovieListState> emit,
  ) async {
    final category = state.category;
    final result = await _repository.getMovies(category: category, page: 1);
    result.fold(
      (failure) =>
          emit(MovieListError(category: category, message: failure.message)),
      (paginated) => emit(
        MovieListLoaded(
          category: category,
          movies: paginated.movies,
          page: paginated.page,
          totalPages: paginated.totalPages,
        ),
      ),
    );
  }
}
