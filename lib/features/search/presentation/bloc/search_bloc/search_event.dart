import 'package:equatable/equatable.dart';

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

/// Append the next page for the active query.
class SearchLoadMore extends SearchEvent {
  const SearchLoadMore();
}

/// Reset to the empty/idle state (e.g. clear button).
class SearchCleared extends SearchEvent {
  const SearchCleared();
}
