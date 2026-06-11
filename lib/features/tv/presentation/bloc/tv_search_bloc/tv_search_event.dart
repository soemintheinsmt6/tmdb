import 'package:equatable/equatable.dart';

abstract class TvSearchEvent extends Equatable {
  const TvSearchEvent();

  @override
  List<Object?> get props => [];
}

/// User typed a new query (debounced upstream).
class TvSearchQueryChanged extends TvSearchEvent {
  const TvSearchQueryChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

/// Append the next page for the active query.
class TvSearchLoadMore extends TvSearchEvent {
  const TvSearchLoadMore();
}

/// Reset to the empty state (e.g. clear button).
class TvSearchCleared extends TvSearchEvent {
  const TvSearchCleared();
}
