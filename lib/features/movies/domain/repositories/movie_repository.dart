import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/movies/domain/entities/movie_detail.dart';
import 'package:tmdb/features/movies/domain/entities/paginated_movies.dart';

/// The TMDB list endpoints exposed in the home screen tabs.
enum MovieCategory { popular, nowPlaying, topRated, upcoming }

/// Repository abstraction the rest of the app depends on. Concrete
/// implementations live in the data layer.
abstract class MovieRepository {
  ResultFuture<PaginatedMovies> getMovies({
    required MovieCategory category,
    int page = 1,
  });

  ResultFuture<PaginatedMovies> searchMovies({
    required String query,
    int page = 1,
  });

  ResultFuture<MovieDetail> getMovieDetail(int id);
}
