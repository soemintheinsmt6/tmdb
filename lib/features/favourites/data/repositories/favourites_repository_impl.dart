import 'package:tmdb/core/storage/object_box.dart';
import 'package:tmdb/features/favourites/data/models/favourite_movie.dart';
import 'package:tmdb/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';
import 'package:tmdb/objectbox.g.dart';

class FavouritesRepositoryImpl implements FavouritesRepository {
  FavouritesRepositoryImpl(ObjectBox objectBox) : _box = objectBox.favouriteBox;

  final Box<FavouriteMovie> _box;

  @override
  Stream<List<Movie>> watchAll() {
    final query = _box
        .query()
        .order(FavouriteMovie_.savedAt, flags: Order.descending)
        .watch(triggerImmediately: true);
    return query.map((q) => q.find().map((f) => f.toMovie()).toList());
  }

  @override
  List<Movie> getAll() {
    final query = _box
        .query()
        .order(FavouriteMovie_.savedAt, flags: Order.descending)
        .build();
    try {
      return query.find().map((f) => f.toMovie()).toList();
    } finally {
      query.close();
    }
  }

  @override
  void toggle(Movie movie) {
    final existing = _findByMovieId(movie.id);
    if (existing != null) {
      _box.remove(existing.id);
      return;
    }
    _box.put(FavouriteMovie.fromMovie(movie));
  }

  @override
  void remove(int movieId) {
    final existing = _findByMovieId(movieId);
    if (existing != null) _box.remove(existing.id);
  }

  @override
  void clear() => _box.removeAll();

  FavouriteMovie? _findByMovieId(int movieId) {
    final query = _box.query(FavouriteMovie_.movieId.equals(movieId)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }
}
