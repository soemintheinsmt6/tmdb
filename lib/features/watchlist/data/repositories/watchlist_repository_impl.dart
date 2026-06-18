import 'package:hive/hive.dart';

import 'package:tmdb/core/storage/hive_storage.dart';
import 'package:tmdb/features/watchlist/data/models/watchlist_entry.dart';
import 'package:tmdb/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:tmdb/features/watchlist/domain/repositories/watchlist_repository.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  WatchlistRepositoryImpl(HiveStorage storage) : _box = storage.watchlistBox;

  /// Keyed by [WatchlistItem.storageKey] (`"movie:550"` / `"tv:1399"`) so a
  /// movie and a TV show that share a numeric id never collide.
  final Box<WatchlistEntry> _box;

  @override
  Stream<List<WatchlistItem>> watchAll() async* {
    yield _snapshot();
    await for (final _ in _box.watch()) {
      yield _snapshot();
    }
  }

  @override
  List<WatchlistItem> getAll() => _snapshot();

  @override
  Future<void> toggle(WatchlistItem item) {
    if (_box.containsKey(item.storageKey)) {
      return _box.delete(item.storageKey);
    }
    return _box.put(item.storageKey, WatchlistEntry.fromItem(item));
  }

  @override
  Future<void> remove(MediaType type, int id) =>
      _box.delete(WatchlistItem.keyFor(type, id));

  @override
  Future<void> clear() => _box.clear();

  List<WatchlistItem> _snapshot() {
    final entries = _box.values.toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return entries.map((e) => e.toItem()).toList();
  }
}
