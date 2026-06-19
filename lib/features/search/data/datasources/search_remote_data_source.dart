import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/features/search/domain/entities/paginated_search_results.dart';
import 'package:tmdb/features/search/domain/entities/search_filter.dart';

class SearchRemoteDataSource {
  const SearchRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Searches the endpoint matching [filter]: `/search/multi` for
  /// [SearchFilter.all], otherwise the type-specific `/search/{movie,tv,person}`
  /// endpoint. The filter's media type is injected into parsing so the
  /// type-specific rows (which lack a `media_type`) are still tagged correctly.
  Future<PaginatedSearchResults> search({
    required String query,
    required SearchFilter filter,
    int page = 1,
  }) async {
    final endpoint = switch (filter) {
      SearchFilter.all => ApiConstants.searchMulti,
      SearchFilter.movie => ApiConstants.searchMovies,
      SearchFilter.tv => ApiConstants.searchTv,
      SearchFilter.person => ApiConstants.searchPerson,
    };
    final response = await _apiClient.get(
      endpoint,
      query: {
        'query': query,
        'page': '$page',
        'language': 'en-US',
        'include_adult': 'false',
      },
    );
    return PaginatedSearchResults.fromJson(
      response as Map<String, dynamic>,
      mediaType: filter.mediaType,
    );
  }
}
