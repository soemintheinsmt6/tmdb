import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:tmdb/features/favourites/data/models/favourite_movie.dart';
import 'package:tmdb/objectbox.g.dart';

/// Wraps the ObjectBox [Store] and exposes typed boxes used across the app.
///
/// Open once at startup via [ObjectBox.create] and pass the instance into the
/// dependency-injection container.
class ObjectBox {
  ObjectBox._(this.store);

  final Store store;

  late final Box<FavouriteMovie> favouriteBox = store.box<FavouriteMovie>();

  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory('${docsDir.path}${Platform.pathSeparator}objectbox');
    final store = await openStore(directory: dbDir.path);
    return ObjectBox._(store);
  }
}
