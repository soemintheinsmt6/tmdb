import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/features/movies/domain/entities/movie_collection.dart';
import 'package:tmdb/features/movies/domain/entities/movie_detail.dart';
import 'package:tmdb/features/movies/domain/entities/paginated_movies.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';
import 'package:tmdb/shared/domain/media/cast_member.dart';
import 'package:tmdb/shared/domain/media/media_image.dart';
import 'package:tmdb/shared/domain/media/review.dart';
import 'package:tmdb/shared/domain/media/video.dart';
import 'package:tmdb/shared/domain/media/watch_providers.dart';

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

  Future<List<Video>> getMovieVideos(int id) async {
    final response = await _apiClient.get(
      ApiConstants.movieVideos(id),
      query: {'language': 'en-US'},
    );
    final json = response as Map<String, dynamic>;
    return ((json['results'] as List?) ?? const [])
        .map((e) => Video.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Review>> getMovieReviews(int id, {int page = 1}) async {
    final response = await _apiClient.get(
      ApiConstants.movieReviews(id),
      query: {'language': 'en-US', 'page': '$page'},
    );
    final json = response as Map<String, dynamic>;
    return ((json['results'] as List?) ?? const [])
        .map((e) => Review.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Backdrops for the gallery. No `language` filter — that would drop the
  /// (numerous) language-agnostic backdrops and leave only localized ones.
  Future<List<MediaImage>> getMovieImages(int id) async {
    final response = await _apiClient.get(ApiConstants.movieImages(id));
    final json = response as Map<String, dynamic>;
    return ((json['backdrops'] as List?) ?? const [])
        .map((e) => MediaImage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Watch options for the user's [region], falling back to `US` when TMDB has
  /// no data for that country, or `null` when neither is available. The
  /// endpoint returns a per-country `results` map.
  Future<WatchProviders?> getMovieWatchProviders(
    int id, {
    required String region,
  }) async {
    final response = await _apiClient.get(ApiConstants.movieWatchProviders(id));
    return parseWatchProviders(
      response as Map<String, dynamic>,
      region: region,
    );
  }

  /// Full franchise (metadata + film parts) from `/collection/{id}`.
  Future<MovieCollection> getCollection(int id) async {
    final response = await _apiClient.get(
      ApiConstants.collection(id),
      query: {'language': 'en-US'},
    );
    return MovieCollection.fromJson(response as Map<String, dynamic>);
  }
}
