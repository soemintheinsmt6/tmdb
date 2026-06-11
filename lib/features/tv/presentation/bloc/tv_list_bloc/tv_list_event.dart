import 'package:equatable/equatable.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';

abstract class TvListEvent extends Equatable {
  const TvListEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch (or refresh) a category's first page.
class TvListCategoryChanged extends TvListEvent {
  const TvListCategoryChanged(this.category);
  final TvCategory category;

  @override
  List<Object?> get props => [category];
}

/// Append the next page for the active category.
class TvListLoadMore extends TvListEvent {
  const TvListLoadMore();
}

/// Pull-to-refresh on the active category.
class TvListRefreshed extends TvListEvent {
  const TvListRefreshed();
}
