import 'package:equatable/equatable.dart';
import 'package:tmdb/features/favourites/domain/entities/favourite_item.dart';

class FavouritesState extends Equatable {
  const FavouritesState({this.items = const [], this.keys = const {}});

  factory FavouritesState.fromItems(List<FavouriteItem> items) {
    return FavouritesState(
      items: items,
      keys: items.map((i) => i.storageKey).toSet(),
    );
  }

  final List<FavouriteItem> items;

  /// Composite membership keys (`"movie:550"` / `"tv:1399"`) for O(1) checks
  /// that respect the media type.
  final Set<String> keys;

  bool contains(MediaType type, int id) =>
      keys.contains(FavouriteItem.keyFor(type, id));

  @override
  List<Object?> get props => [items, keys];
}
