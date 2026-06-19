import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/features/discover/domain/entities/discover_filter.dart';
import 'package:tmdb/features/movies/domain/entities/paginated_movies.dart';
import 'package:tmdb/features/tv/domain/entities/paginated_tv_shows.dart';
import 'package:tmdb/shared/domain/media/genre.dart';

/// Network-only client for the discover feature. Throws the exceptions defined
/// in `core/error/exceptions.dart`; the repository converts them to `Failure`s.
class DiscoverRemoteDataSource {
  const DiscoverRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<PaginatedMovies> discoverMovies({
    required DiscoverFilter filter,
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.discoverMovie,
      query: {...filter.toQuery(), 'language': 'en-US', 'page': '$page'},
    );
    return PaginatedMovies.fromJson(response as Map<String, dynamic>);
  }

  Future<PaginatedTvShows> discoverTv({
    required DiscoverFilter filter,
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.discoverTv,
      query: {...filter.toQuery(), 'language': 'en-US', 'page': '$page'},
    );
    return PaginatedTvShows.fromJson(response as Map<String, dynamic>);
  }

  Future<List<Genre>> getMovieGenres() async {
    final response = await _apiClient.get(
      ApiConstants.movieGenres,
      query: {'language': 'en-US'},
    );
    return _parseGenres(response);
  }

  Future<List<Genre>> getTvGenres() async {
    final response = await _apiClient.get(
      ApiConstants.tvGenres,
      query: {'language': 'en-US'},
    );
    return _parseGenres(response);
  }

  List<Genre> _parseGenres(dynamic response) {
    final json = response as Map<String, dynamic>;
    return ((json['genres'] as List?) ?? const [])
        .map((e) => Genre.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
