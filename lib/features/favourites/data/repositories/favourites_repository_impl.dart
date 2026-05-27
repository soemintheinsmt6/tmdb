import 'package:hive/hive.dart';

import 'package:tmdb/core/storage/hive_storage.dart';
import 'package:tmdb/features/favourites/data/models/favourite_movie.dart';
import 'package:tmdb/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';

class FavouritesRepositoryImpl implements FavouritesRepository {
  FavouritesRepositoryImpl(HiveStorage storage) : _box = storage.favouriteBox;

  final Box<FavouriteMovie> _box;

  @override
  Stream<List<Movie>> watchAll() async* {
    yield _snapshot();
    await for (final _ in _box.watch()) {
      yield _snapshot();
    }
  }

  @override
  List<Movie> getAll() => _snapshot();

  @override
  Future<void> toggle(Movie movie) {
    if (_box.containsKey(movie.id)) {
      return _box.delete(movie.id);
    }
    return _box.put(movie.id, FavouriteMovie.fromMovie(movie));
  }

  @override
  Future<void> remove(int movieId) => _box.delete(movieId);

  @override
  Future<void> clear() => _box.clear();

  List<Movie> _snapshot() {
    final favourites = _box.values.toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return favourites.map((f) => f.toMovie()).toList();
  }
}
