import 'package:hive_flutter/hive_flutter.dart';

import 'package:tmdb/features/favourites/data/models/favourite_movie.dart';
import 'package:tmdb/features/favourites/data/models/favourite_tv_show.dart';
import 'package:tmdb/features/watchlist/data/models/watchlist_entry.dart';

/// Wraps Hive setup and exposes typed boxes used across the app.
///
/// Open once at startup via [HiveStorage.create] and pass the instance into
/// the dependency-injection container.
class HiveStorage {
  HiveStorage._(
    this.favouriteBox,
    this.favouriteTvBox,
    this.watchlistBox,
    this.settingsBox,
  );

  final Box<FavouriteMovie> favouriteBox;
  final Box<FavouriteTvShow> favouriteTvBox;
  final Box<WatchlistEntry> watchlistBox;

  /// Untyped key/value box for primitive user preferences (e.g. theme mode).
  final Box<dynamic> settingsBox;

  static const String favouriteBoxName = 'favourites';
  static const String favouriteTvBoxName = 'favourite_tv';
  static const String watchlistBoxName = 'watchlist';
  static const String settingsBoxName = 'settings';

  static Future<HiveStorage> create() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(FavouriteMovieAdapter.kTypeId)) {
      Hive.registerAdapter(FavouriteMovieAdapter());
    }
    if (!Hive.isAdapterRegistered(FavouriteTvShowAdapter.kTypeId)) {
      Hive.registerAdapter(FavouriteTvShowAdapter());
    }
    if (!Hive.isAdapterRegistered(WatchlistEntryAdapter.kTypeId)) {
      Hive.registerAdapter(WatchlistEntryAdapter());
    }
    final favouriteBox = await Hive.openBox<FavouriteMovie>(favouriteBoxName);
    final favouriteTvBox = await Hive.openBox<FavouriteTvShow>(
      favouriteTvBoxName,
    );
    final watchlistBox = await Hive.openBox<WatchlistEntry>(watchlistBoxName);
    final settingsBox = await Hive.openBox<dynamic>(settingsBoxName);
    return HiveStorage._(
      favouriteBox,
      favouriteTvBox,
      watchlistBox,
      settingsBox,
    );
  }
}
