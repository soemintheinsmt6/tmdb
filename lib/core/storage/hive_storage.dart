import 'package:hive_flutter/hive_flutter.dart';

import 'package:tmdb/features/favourites/data/models/favourite_movie.dart';

/// Wraps Hive setup and exposes typed boxes used across the app.
///
/// Open once at startup via [HiveStorage.create] and pass the instance into
/// the dependency-injection container.
class HiveStorage {
  HiveStorage._(this.favouriteBox);

  final Box<FavouriteMovie> favouriteBox;

  static const String favouriteBoxName = 'favourites';

  static Future<HiveStorage> create() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(FavouriteMovieAdapter.kTypeId)) {
      Hive.registerAdapter(FavouriteMovieAdapter());
    }
    final box = await Hive.openBox<FavouriteMovie>(favouriteBoxName);
    return HiveStorage._(box);
  }
}
