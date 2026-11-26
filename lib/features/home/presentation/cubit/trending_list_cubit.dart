import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/features/home/domain/repositories/trending_repository.dart';
import 'package:tmdb/features/home/presentation/cubit/trending_list_state.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';

/// Drives the paged trending grid: first page via [load], infinite scroll via
/// [loadMore].
class TrendingListCubit extends Cubit<TrendingListState> {
  TrendingListCubit(this._repository) : super(const TrendingListState());

  final TrendingRepository _repository;

  Future<void> load() async {
    emit(const TrendingListState(status: TrendingListStatus.loading));
    final result = await _repository.getTrendingPage(page: 1);
    result.fold(
      (failure) => emit(
        TrendingListState(
          status: TrendingListStatus.error,
          message: failure.message,
        ),
      ),
      (paginated) => emit(
        TrendingListState(
          status: TrendingListStatus.loaded,
          items: paginated.items,
          page: paginated.page,
          totalPages: paginated.totalPages,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state;
    if (current.status != TrendingListStatus.loaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    final result = await _repository.getTrendingPage(page: current.page + 1);
    result.fold((_) => emit(current.copyWith(isLoadingMore: false)), (
      paginated,
    ) {
      // Trending shifts while paging, so a title can reappear on a later
      // page; keep only its first occurrence.
      final seen = {for (final item in current.items) _key(item)};
      emit(
        current.copyWith(
          items: [
            ...current.items,
            ...paginated.items.where((item) => seen.add(_key(item))),
          ],
          page: paginated.page,
          totalPages: paginated.totalPages,
          isLoadingMore: false,
        ),
      );
    });
  }

  /// Movie and TV ids overlap, so the key includes the type.
  static String _key(PosterItem item) => '${item.runtimeType}:${item.id}';
}
