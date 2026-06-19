import 'package:equatable/equatable.dart';
import 'package:tmdb/features/search/domain/entities/search_filter.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// User typed a new query (debounced upstream).
class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

/// User picked a media-type filter; re-runs the active query in that scope.
class SearchFilterChanged extends SearchEvent {
  const SearchFilterChanged(this.filter);
  final SearchFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Append the next page for the active query.
class SearchLoadMore extends SearchEvent {
  const SearchLoadMore();
}

/// Reset to the empty/idle state (e.g. clear button).
class SearchCleared extends SearchEvent {
  const SearchCleared();
}
