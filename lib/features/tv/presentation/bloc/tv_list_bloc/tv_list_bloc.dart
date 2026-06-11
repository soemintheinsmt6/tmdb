import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';

import 'tv_list_event.dart';
import 'tv_list_state.dart';

class TvListBloc extends Bloc<TvListEvent, TvListState> {
  TvListBloc({
    required TvRepository repository,
    TvCategory initialCategory = TvCategory.popular,
  }) : _repository = repository,
       super(TvListInitial(category: initialCategory)) {
    on<TvListCategoryChanged>(_onCategoryChanged);
    on<TvListLoadMore>(_onLoadMore);
    on<TvListRefreshed>(_onRefreshed);

    add(TvListCategoryChanged(initialCategory));
  }

  final TvRepository _repository;

  Future<void> _onCategoryChanged(
    TvListCategoryChanged event,
    Emitter<TvListState> emit,
  ) async {
    emit(TvListLoading(category: event.category));
    final result = await _repository.getTvShows(
      category: event.category,
      page: 1,
    );
    result.fold(
      (failure) =>
          emit(TvListError(category: event.category, message: failure.message)),
      (paginated) => emit(
        TvListLoaded(
          category: event.category,
          shows: paginated.shows,
          page: paginated.page,
          totalPages: paginated.totalPages,
        ),
      ),
    );
  }

  Future<void> _onLoadMore(
    TvListLoadMore event,
    Emitter<TvListState> emit,
  ) async {
    final current = state;
    if (current is! TvListLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    final result = await _repository.getTvShows(
      category: current.category,
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

  Future<void> _onRefreshed(
    TvListRefreshed event,
    Emitter<TvListState> emit,
  ) async {
    final category = state.category;
    final result = await _repository.getTvShows(category: category, page: 1);
    result.fold(
      (failure) =>
          emit(TvListError(category: category, message: failure.message)),
      (paginated) => emit(
        TvListLoaded(
          category: category,
          shows: paginated.shows,
          page: paginated.page,
          totalPages: paginated.totalPages,
        ),
      ),
    );
  }
}
