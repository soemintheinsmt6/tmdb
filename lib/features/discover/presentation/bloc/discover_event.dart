import 'package:equatable/equatable.dart';
import 'package:tmdb/features/discover/domain/entities/discover_filter.dart';

abstract class DiscoverEvent extends Equatable {
  const DiscoverEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the genre list and the first page for the default filter. Fired once
/// when the screen mounts.
class DiscoverStarted extends DiscoverEvent {
  const DiscoverStarted();
}

/// Switches the browse vertical (movies ↔ TV). Resets the genre selection
/// (genre ids differ between verticals), reloads that vertical's genres, and
/// fetches page 1.
class DiscoverMediaTypeChanged extends DiscoverEvent {
  const DiscoverMediaTypeChanged(this.mediaType);
  final MediaType mediaType;

  @override
  List<Object?> get props => [mediaType];
}

/// Applies a new [filter] and reloads from page 1.
class DiscoverFilterApplied extends DiscoverEvent {
  const DiscoverFilterApplied(this.filter);
  final DiscoverFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Appends the next page for the active filter.
class DiscoverLoadMore extends DiscoverEvent {
  const DiscoverLoadMore();
}

/// Pull-to-refresh: reloads page 1 for the active filter.
class DiscoverRefreshed extends DiscoverEvent {
  const DiscoverRefreshed();
}
