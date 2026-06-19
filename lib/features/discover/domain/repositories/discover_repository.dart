import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/discover/domain/entities/discover_filter.dart';
import 'package:tmdb/features/movies/domain/entities/paginated_movies.dart';
import 'package:tmdb/features/tv/domain/entities/paginated_tv_shows.dart';
import 'package:tmdb/shared/domain/media/genre.dart';

/// Repository abstraction for the discover/browse feature.
abstract class DiscoverRepository {
  /// Paginated `/discover/movie` results for the given [filter].
  ResultFuture<PaginatedMovies> discoverMovies({
    required DiscoverFilter filter,
    int page = 1,
  });

  /// Paginated `/discover/tv` results for the given [filter].
  ResultFuture<PaginatedTvShows> discoverTv({
    required DiscoverFilter filter,
    int page = 1,
  });

  /// The movie genre list used to populate the filter sheet.
  ResultFuture<List<Genre>> getMovieGenres();

  /// The TV genre list used to populate the filter sheet.
  ResultFuture<List<Genre>> getTvGenres();
}
