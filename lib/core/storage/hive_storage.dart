import 'package:hive_flutter/hive_flutter.dart';

import 'package:tmdb/features/favourites/data/models/favourite_movie.dart';
import 'package:tmdb/features/watchlist/data/models/watchlist_entry.dart';

/// Wraps Hive setup and exposes typed boxes used across the app.
///
/// Open once at startup via [HiveStorage.create] and pass the instance into
/// the dependency-injection container.
class HiveStorage {
  HiveStorage._(this.favouriteBox, this.watchlistBox);

  final Box<FavouriteMovie> favouriteBox;
  final Box<WatchlistEntry> watchlistBox;

  static const String favouriteBoxName = 'favourites';
  static const String watchlistBoxName = 'watchlist';

  static Future<HiveStorage> create() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(FavouriteMovieAdapter.kTypeId)) {
      Hive.registerAdapter(FavouriteMovieAdapter());
    }
    if (!Hive.isAdapterRegistered(WatchlistEntryAdapter.kTypeId)) {
      Hive.registerAdapter(WatchlistEntryAdapter());
    }
    final favouriteBox = await Hive.openBox<FavouriteMovie>(favouriteBoxName);
    final watchlistBox = await Hive.openBox<WatchlistEntry>(watchlistBoxName);
    return HiveStorage._(favouriteBox, watchlistBox);
  }
}
