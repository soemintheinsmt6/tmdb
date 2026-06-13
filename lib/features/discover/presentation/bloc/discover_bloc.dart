import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/features/discover/domain/entities/discover_filter.dart';
import 'package:tmdb/features/discover/domain/repositories/discover_repository.dart';
import 'package:tmdb/shared/domain/genre.dart';

import 'discover_event.dart';
import 'discover_state.dart';

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  DiscoverBloc({required DiscoverRepository repository})
    : _repository = repository,
      super(const DiscoverState()) {
    on<DiscoverStarted>(_onStarted);
    on<DiscoverFilterApplied>(_onFilterApplied);
    on<DiscoverLoadMore>(_onLoadMore);
    on<DiscoverRefreshed>(_onRefreshed);
  }

  final DiscoverRepository _repository;

  Future<void> _onStarted(
    DiscoverStarted event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(state.copyWith(status: DiscoverStatus.loading));
    // Genres are best-effort: a failure here just leaves the genre filter empty.
    final genresResult = await _repository.getMovieGenres();
    final genres = genresResult.getOrElse(() => state.genres);
    await _loadFirstPage(emit, state.filter, genres: genres);
  }

  Future<void> _onFilterApplied(
    DiscoverFilterApplied event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(state.copyWith(status: DiscoverStatus.loading, filter: event.filter));
    await _loadFirstPage(emit, event.filter);
  }

  Future<void> _onRefreshed(
    DiscoverRefreshed event,
    Emitter<DiscoverState> emit,
  ) async {
    await _loadFirstPage(emit, state.filter);
  }

  /// Loads page 1 for [filter]. [genres] is passed only by [DiscoverStarted];
  /// when null, the existing genres in state are preserved via copyWith.
  Future<void> _loadFirstPage(
    Emitter<DiscoverState> emit,
    DiscoverFilter filter, {
    List<Genre>? genres,
  }) async {
    final result = await _repository.discoverMovies(filter: filter, page: 1);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DiscoverStatus.error,
          message: failure.message,
          genres: genres,
        ),
      ),
      (paginated) => emit(
        state.copyWith(
          status: DiscoverStatus.loaded,
          genres: genres,
          movies: paginated.movies,
          page: paginated.page,
          totalPages: paginated.totalPages,
          isLoadingMore: false,
        ),
      ),
    );
  }

  Future<void> _onLoadMore(
    DiscoverLoadMore event,
    Emitter<DiscoverState> emit,
  ) async {
    if (state.status != DiscoverStatus.loaded) return;
    if (!state.hasMore || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));
    final result = await _repository.discoverMovies(
      filter: state.filter,
      page: state.page + 1,
    );
    result.fold(
      (_) => emit(state.copyWith(isLoadingMore: false)),
      (paginated) => emit(
        state.copyWith(
          movies: [...state.movies, ...paginated.movies],
          page: paginated.page,
          totalPages: paginated.totalPages,
          isLoadingMore: false,
        ),
      ),
    );
  }
}
