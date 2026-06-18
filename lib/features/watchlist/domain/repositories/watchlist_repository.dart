import 'package:tmdb/features/watchlist/domain/entities/watchlist_item.dart';

/// Abstraction over the watchlist store. Surface uses [WatchlistItem] only —
/// the Hive row type stays inside the impl. Mirrors `FavouritesRepository`, but
/// covers both movies and TV shows.
abstract class WatchlistRepository {
  /// Reactive list of saved titles, newest first. Emits the current snapshot
  /// immediately on subscribe.
  Stream<List<WatchlistItem>> watchAll();

  /// Synchronous snapshot used to seed initial cubit state without a frame of
  /// empty UI before [watchAll]'s first async emit.
  List<WatchlistItem> getAll();

  /// Adds when missing, removes when present (keyed by media type + id).
  Future<void> toggle(WatchlistItem item);

  Future<void> remove(MediaType type, int id);

  Future<void> clear();
}
