import 'package:equatable/equatable.dart';
import 'package:tmdb/features/watchlist/domain/entities/watchlist_item.dart';

class WatchlistState extends Equatable {
  const WatchlistState({this.items = const [], this.keys = const {}});

  factory WatchlistState.fromItems(List<WatchlistItem> items) {
    return WatchlistState(
      items: items,
      keys: items.map((i) => i.storageKey).toSet(),
    );
  }

  final List<WatchlistItem> items;

  /// Composite storage keys (`"movie:550"` / `"tv:1399"`) for O(1) membership
  /// checks that respect the media type.
  final Set<String> keys;

  bool contains(MediaType type, int id) =>
      keys.contains(WatchlistItem.keyFor(type, id));

  @override
  List<Object?> get props => [items, keys];
}
