import 'package:tmdb/core/storage/object_box.dart';
import 'package:tmdb/features/favourites/data/models/favourite_movie.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';
import 'package:tmdb/objectbox.g.dart';

/// CRUD + reactive queries for the user's favourited movies.
class FavouritesRepository {
  FavouritesRepository(ObjectBox objectBox) : _box = objectBox.favouriteBox;

  final Box<FavouriteMovie> _box;

  Stream<List<FavouriteMovie>> watchAll() {
    final query = _box
        .query()
        .order(FavouriteMovie_.savedAt, flags: Order.descending)
        .watch(triggerImmediately: true);
    return query.map((q) => q.find());
  }

  List<FavouriteMovie> getAll() {
    final query = _box
        .query()
        .order(FavouriteMovie_.savedAt, flags: Order.descending)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  bool isFavourite(int movieId) {
    final query = _box.query(FavouriteMovie_.movieId.equals(movieId)).build();
    try {
      return query.count() > 0;
    } finally {
      query.close();
    }
  }

  /// Adds when missing, removes when present. Returns the resulting state.
  bool toggle(Movie movie) {
    final existing = _findByMovieId(movie.id);
    if (existing != null) {
      _box.remove(existing.id);
      return false;
    }
    _box.put(FavouriteMovie.fromMovie(movie));
    return true;
  }

  void removeByMovieId(int movieId) {
    final existing = _findByMovieId(movieId);
    if (existing != null) _box.remove(existing.id);
  }

  void removeAll() => _box.removeAll();

  FavouriteMovie? _findByMovieId(int movieId) {
    final query = _box.query(FavouriteMovie_.movieId.equals(movieId)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }
}
