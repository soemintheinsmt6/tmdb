import 'package:equatable/equatable.dart';

sealed class TvFeedEvent extends Equatable {
  const TvFeedEvent();

  @override
  List<Object?> get props => [];
}

/// First load — fans out across the trending hero and every TV category rail.
class TvFeedStarted extends TvFeedEvent {
  const TvFeedStarted();
}

/// Pull-to-refresh — reloads every rail in place.
class TvFeedRefreshed extends TvFeedEvent {
  const TvFeedRefreshed();
}
