import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/features/search/domain/repositories/search_repository.dart';

import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required SearchRepository repository})
    : _repository = repository,
      super(const SearchIdle()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchLoadMore>(_onLoadMore);
    on<SearchCleared>(_onCleared);
  }

  final SearchRepository _repository;

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const SearchIdle());
      return;
    }

    emit(const SearchLoading());
    final result = await _repository.searchMulti(query: query, page: 1);

    // Drop late results — only commit if the query is still the latest one the
    // bloc has been told about.
    if (state is! SearchLoading) return;

    result.fold(
      (failure) => emit(SearchError(message: failure.message)),
      (paginated) => emit(
        SearchLoaded(
          query: query,
          results: paginated.results,
          page: paginated.page,
          totalPages: paginated.totalPages,
        ),
      ),
    );
  }

  Future<void> _onLoadMore(
    SearchLoadMore event,
    Emitter<SearchState> emit,
  ) async {
    final current = state;
    if (current is! SearchLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    final result = await _repository.searchMulti(
      query: current.query,
      page: current.page + 1,
    );

    result.fold(
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (paginated) => emit(
        current.copyWith(
          results: [...current.results, ...paginated.results],
          page: paginated.page,
          totalPages: paginated.totalPages,
          isLoadingMore: false,
        ),
      ),
    );
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    emit(const SearchIdle());
  }
}
