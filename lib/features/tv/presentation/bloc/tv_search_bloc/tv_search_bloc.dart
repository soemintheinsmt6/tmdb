import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';

import 'tv_search_event.dart';
import 'tv_search_state.dart';

class TvSearchBloc extends Bloc<TvSearchEvent, TvSearchState> {
  TvSearchBloc({required TvRepository repository})
    : _repository = repository,
      super(const TvSearchIdle()) {
    on<TvSearchQueryChanged>(_onQueryChanged);
    on<TvSearchLoadMore>(_onLoadMore);
    on<TvSearchCleared>(_onCleared);
  }

  final TvRepository _repository;

  Future<void> _onQueryChanged(
    TvSearchQueryChanged event,
    Emitter<TvSearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const TvSearchIdle());
      return;
    }

    emit(const TvSearchLoading());
    final result = await _repository.searchTvShows(query: query, page: 1);

    // Drop late results — only commit if the query is still the latest one
    // the bloc has been told about.
    if (state is! TvSearchLoading) return;

    result.fold(
      (failure) => emit(TvSearchError(message: failure.message)),
      (paginated) => emit(
        TvSearchLoaded(
          query: query,
          shows: paginated.shows,
          page: paginated.page,
          totalPages: paginated.totalPages,
        ),
      ),
    );
  }

  Future<void> _onLoadMore(
    TvSearchLoadMore event,
    Emitter<TvSearchState> emit,
  ) async {
    final current = state;
    if (current is! TvSearchLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    final result = await _repository.searchTvShows(
      query: current.query,
      page: current.page + 1,
    );

    result.fold(
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (paginated) => emit(
        current.copyWith(
          shows: [...current.shows, ...paginated.shows],
          page: paginated.page,
          totalPages: paginated.totalPages,
          isLoadingMore: false,
        ),
      ),
    );
  }

  void _onCleared(TvSearchCleared event, Emitter<TvSearchState> emit) {
    emit(const TvSearchIdle());
  }
}
