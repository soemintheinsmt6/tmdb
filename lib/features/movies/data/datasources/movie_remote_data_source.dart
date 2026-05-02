import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/features/movies/domain/entities/cast_member.dart';
import 'package:tmdb/features/movies/domain/entities/movie_detail.dart';
import 'package:tmdb/features/movies/domain/entities/paginated_movies.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';

/// Network-only client for the movies feature. Throws the exceptions defined
/// in `core/error/exceptions.dart`; the repository converts them to
/// `Failure`s.
class MovieRemoteDataSource {
  const MovieRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  String _endpointFor(MovieCategory category) {
    return switch (category) {
      MovieCategory.popular => ApiConstants.popularMovies,
      MovieCategory.nowPlaying => ApiConstants.nowPlayingMovies,
      MovieCategory.topRated => ApiConstants.topRatedMovies,
      MovieCategory.upcoming => ApiConstants.upcomingMovies,
    };
  }

  Future<PaginatedMovies> getMovies({
    required MovieCategory category,
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      _endpointFor(category),
      query: {'page': '$page', 'language': 'en-US'},
    );
    return PaginatedMovies.fromJson(response as Map<String, dynamic>);
  }

  Future<PaginatedMovies> searchMovies({
    required String query,
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.searchMovies,
      query: {
        'query': query,
        'page': '$page',
        'language': 'en-US',
        'include_adult': 'false',
      },
    );
    return PaginatedMovies.fromJson(response as Map<String, dynamic>);
  }

  Future<MovieDetail> getMovieDetail(int id) async {
    final response = await _apiClient.get(
      ApiConstants.movieDetail(id),
      query: {'language': 'en-US'},
    );
    return MovieDetail.fromJson(response as Map<String, dynamic>);
  }

  Future<List<CastMember>> getMovieCredits(int id) async {
    final response = await _apiClient.get(
      ApiConstants.movieCredits(id),
      query: {'language': 'en-US'},
    );
    final json = response as Map<String, dynamic>;
    return ((json['cast'] as List?) ?? const [])
        .map((e) => CastMember.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<PaginatedMovies> getMovieRecommendations(
    int id, {
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.movieRecommendations(id),
      query: {'language': 'en-US', 'page': '$page'},
    );
    return PaginatedMovies.fromJson(response as Map<String, dynamic>);
  }
}
