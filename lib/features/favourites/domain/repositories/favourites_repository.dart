import 'package:tmdb/features/movies/domain/entities/movie.dart';

/// Abstraction over the favourites store. Surface uses [Movie] only — the
/// Hive row type stays inside the impl.
abstract class FavouritesRepository {
  /// Reactive list of favourited movies, newest first. Emits the current
  /// snapshot immediately on subscribe.
  Stream<List<Movie>> watchAll();

  /// Synchronous snapshot used to seed initial cubit state without a frame
  /// of empty UI before [watchAll]'s first async emit.
  List<Movie> getAll();

  /// Adds when missing, removes when present.
  Future<void> toggle(Movie movie);

  Future<void> remove(int movieId);

  Future<void> clear();
}
