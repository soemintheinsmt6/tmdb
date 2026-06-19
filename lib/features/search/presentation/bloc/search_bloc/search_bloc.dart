import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/features/search/domain/entities/search_filter.dart';
import 'package:tmdb/features/search/domain/repositories/search_repository.dart';

import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required SearchRepository repository})
    : _repository = repository,
      super(const SearchIdle()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchFilterChanged>(_onFilterChanged);
    on<SearchLoadMore>(_onLoadMore);
    on<SearchCleared>(_onCleared);
  }

  final SearchRepository _repository;

  // The active query and media-type scope. Held here (rather than only on
  // [SearchLoaded]) so a filter change can re-run the latest query, and so
  // pagination knows which endpoint to page.
  String _query = '';
  SearchFilter _filter = SearchFilter.all;

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    _query = event.query.trim();
    if (_query.isEmpty) {
      emit(const SearchIdle());
      return;
    }
    await _runSearch(emit);
  }

  Future<void> _onFilterChanged(
    SearchFilterChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.filter == _filter) return;
    _filter = event.filter;
    // Nothing to re-scope until there's a query; the UI reflects the new chip.
    if (_query.isEmpty) return;
    await _runSearch(emit);
  }

  /// Runs the active [_query] in the active [_filter] scope from page 1.
  Future<void> _runSearch(Emitter<SearchState> emit) async {
    emit(const SearchLoading());
    final result = await _repository.search(
      query: _query,
      filter: _filter,
      page: 1,
    );

    // Drop late results — only commit if this is still the latest run (a newer
    // query or filter change would have moved us past Loading).
    if (state is! SearchLoading) return;

    result.fold(
      (failure) => emit(SearchError(message: failure.message)),
      (paginated) => emit(
        SearchLoaded(
          query: _query,
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
    final result = await _repository.search(
      query: _query,
      filter: _filter,
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
    _query = '';
    emit(const SearchIdle());
  }
}
