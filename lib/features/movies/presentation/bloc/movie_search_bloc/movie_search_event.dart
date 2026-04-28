import 'package:equatable/equatable.dart';

abstract class MovieSearchEvent extends Equatable {
  const MovieSearchEvent();

  @override
  List<Object?> get props => [];
}

/// User typed a new query (debounced upstream).
class MovieSearchQueryChanged extends MovieSearchEvent {
  const MovieSearchQueryChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

/// Append the next page for the active query.
class MovieSearchLoadMore extends MovieSearchEvent {
  const MovieSearchLoadMore();
}

/// Reset to the empty state (e.g. clear button).
class MovieSearchCleared extends MovieSearchEvent {
  const MovieSearchCleared();
}
