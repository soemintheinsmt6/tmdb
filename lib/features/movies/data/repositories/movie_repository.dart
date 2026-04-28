import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/movies/data/models/movie_detail.dart';
import 'package:tmdb/features/movies/data/models/paginated_movies.dart';

/// The TMDB list endpoints exposed in the home screen tabs.
enum MovieCategory { popular, nowPlaying, topRated, upcoming }

abstract class MovieRepository {
  /// GET `/movie/{category}?page=`.
  ResultFuture<PaginatedMovies> getMovies({
    required MovieCategory category,
    int page = 1,
  });

  /// GET `/search/movie?query=&page=`.
  ResultFuture<PaginatedMovies> searchMovies({
    required String query,
    int page = 1,
  });

  /// Fetches `/movie/{id}` plus credits and recommendations in parallel.
  ResultFuture<MovieDetail> getMovieDetail(int id);
}
