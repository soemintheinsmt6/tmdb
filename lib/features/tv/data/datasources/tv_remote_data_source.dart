import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/features/tv/domain/entities/paginated_tv_shows.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show_detail.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/shared/domain/cast_member.dart';
import 'package:tmdb/shared/domain/review.dart';
import 'package:tmdb/shared/domain/video.dart';

/// Network-only client for the TV feature. Throws the exceptions defined in
/// `core/error/exceptions.dart`; the repository converts them to `Failure`s.
class TvRemoteDataSource {
  const TvRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  String _endpointFor(TvCategory category) {
    return switch (category) {
      TvCategory.popular => ApiConstants.popularTv,
      TvCategory.topRated => ApiConstants.topRatedTv,
      TvCategory.onTheAir => ApiConstants.onTheAirTv,
      TvCategory.airingToday => ApiConstants.airingTodayTv,
    };
  }

  Future<PaginatedTvShows> getTvShows({
    required TvCategory category,
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      _endpointFor(category),
      query: {'page': '$page', 'language': 'en-US'},
    );
    return PaginatedTvShows.fromJson(response as Map<String, dynamic>);
  }

  Future<PaginatedTvShows> searchTvShows({
    required String query,
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.searchTv,
      query: {
        'query': query,
        'page': '$page',
        'language': 'en-US',
        'include_adult': 'false',
      },
    );
    return PaginatedTvShows.fromJson(response as Map<String, dynamic>);
  }

  Future<TvShowDetail> getTvShowDetail(int id) async {
    final response = await _apiClient.get(
      ApiConstants.tvDetail(id),
      query: {'language': 'en-US'},
    );
    return TvShowDetail.fromJson(response as Map<String, dynamic>);
  }

  Future<List<CastMember>> getTvCredits(int id) async {
    final response = await _apiClient.get(
      ApiConstants.tvCredits(id),
      query: {'language': 'en-US'},
    );
    final json = response as Map<String, dynamic>;
    return ((json['cast'] as List?) ?? const [])
        .map((e) => CastMember.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<PaginatedTvShows> getTvRecommendations(int id, {int page = 1}) async {
    final response = await _apiClient.get(
      ApiConstants.tvRecommendations(id),
      query: {'language': 'en-US', 'page': '$page'},
    );
    return PaginatedTvShows.fromJson(response as Map<String, dynamic>);
  }

  Future<List<Video>> getTvVideos(int id) async {
    final response = await _apiClient.get(
      ApiConstants.tvVideos(id),
      query: {'language': 'en-US'},
    );
    final json = response as Map<String, dynamic>;
    return ((json['results'] as List?) ?? const [])
        .map((e) => Video.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Review>> getTvReviews(int id, {int page = 1}) async {
    final response = await _apiClient.get(
      ApiConstants.tvReviews(id),
      query: {'language': 'en-US', 'page': '$page'},
    );
    final json = response as Map<String, dynamic>;
    return ((json['results'] as List?) ?? const [])
        .map((e) => Review.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
