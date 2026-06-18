import 'dart:async';

import 'package:hive/hive.dart';

import 'package:tmdb/core/storage/hive_storage.dart';
import 'package:tmdb/features/favourites/data/models/favourite_movie.dart';
import 'package:tmdb/features/favourites/data/models/favourite_tv_show.dart';
import 'package:tmdb/features/favourites/domain/entities/favourite_item.dart';
import 'package:tmdb/features/favourites/domain/repositories/favourites_repository.dart';

/// Favourites are stored in two type-specific Hive boxes (movies keep their
/// original box untouched; TV shows get their own). Each box is keyed by the
/// raw numeric id — no collisions, since the type is implied by the box — and
/// the repository merges both into one [FavouriteItem] stream at the boundary.
class FavouritesRepositoryImpl implements FavouritesRepository {
  FavouritesRepositoryImpl(HiveStorage storage)
    : _movieBox = storage.favouriteBox,
      _tvBox = storage.favouriteTvBox;

  final Box<FavouriteMovie> _movieBox;
  final Box<FavouriteTvShow> _tvBox;

  @override
  Stream<List<FavouriteItem>> watchAll() async* {
    yield _snapshot();
    await for (final _ in _changes()) {
      yield _snapshot();
    }
  }

  @override
  List<FavouriteItem> getAll() => _snapshot();

  @override
  Future<void> toggle(FavouriteItem item) {
    switch (item.mediaType) {
      case MediaType.movie:
        return _movieBox.containsKey(item.id)
            ? _movieBox.delete(item.id)
            : _movieBox.put(item.id, FavouriteMovie.fromItem(item));
      case MediaType.tv:
        return _tvBox.containsKey(item.id)
            ? _tvBox.delete(item.id)
            : _tvBox.put(item.id, FavouriteTvShow.fromItem(item));
    }
  }

  @override
  Future<void> remove(MediaType type, int id) {
    switch (type) {
      case MediaType.movie:
        return _movieBox.delete(id);
      case MediaType.tv:
        return _tvBox.delete(id);
    }
  }

  @override
  Future<void> clear() async {
    await _movieBox.clear();
    await _tvBox.clear();
  }

  List<FavouriteItem> _snapshot() {
    final items = <FavouriteItem>[
      ..._movieBox.values.map((m) => m.toFavouriteItem()),
      ..._tvBox.values.map((t) => t.toFavouriteItem()),
    ]..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return items;
  }

  /// Single change signal fanned in from both boxes' watch streams.
  Stream<void> _changes() {
    StreamSubscription<BoxEvent>? movieSub;
    StreamSubscription<BoxEvent>? tvSub;
    late final StreamController<void> controller;
    controller = StreamController<void>(
      onListen: () {
        movieSub = _movieBox.watch().listen((_) => controller.add(null));
        tvSub = _tvBox.watch().listen((_) => controller.add(null));
      },
      onCancel: () async {
        await movieSub?.cancel();
        await tvSub?.cancel();
      },
    );
    return controller.stream;
  }
}
