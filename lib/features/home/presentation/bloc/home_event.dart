import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// First load — triggers the concurrent fan-out across all rails.
class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// Pull-to-refresh — reloads every rail in place.
class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}

/// Recompute only the personalised "For You" rail. Fired (debounced) when the
/// user's favourites or watchlist change.
class HomeForYouRefreshRequested extends HomeEvent {
  const HomeForYouRefreshRequested();
}
