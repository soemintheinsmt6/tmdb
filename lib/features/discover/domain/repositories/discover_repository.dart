import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/discover/domain/entities/discover_filter.dart';
import 'package:tmdb/features/movies/domain/entities/paginated_movies.dart';
import 'package:tmdb/shared/domain/genre.dart';

/// Repository abstraction for the discover/browse feature.
abstract class DiscoverRepository {
  /// Paginated `/discover/movie` results for the given [filter].
  ResultFuture<PaginatedMovies> discoverMovies({
    required DiscoverFilter filter,
    int page = 1,
  });

  /// The movie genre list used to populate the filter sheet.
  ResultFuture<List<Genre>> getMovieGenres();
}
