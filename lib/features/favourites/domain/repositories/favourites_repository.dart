import 'package:tmdb/features/favourites/domain/entities/favourite_item.dart';

/// Abstraction over the favourites store. Surface uses [FavouriteItem] only —
/// the Hive row types stay inside the impl. Spans both movies and TV shows.
abstract class FavouritesRepository {
  /// Reactive list of favourited titles, newest first. Emits the current
  /// snapshot immediately on subscribe.
  Stream<List<FavouriteItem>> watchAll();

  /// Synchronous snapshot used to seed initial cubit state without a frame of
  /// empty UI before [watchAll]'s first async emit.
  List<FavouriteItem> getAll();

  /// Adds when missing, removes when present (keyed by media type + id).
  Future<void> toggle(FavouriteItem item);

  Future<void> remove(MediaType type, int id);

  Future<void> clear();
}
