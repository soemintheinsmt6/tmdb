import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/features/search/domain/entities/paginated_search_results.dart';

class SearchRemoteDataSource {
  const SearchRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<PaginatedSearchResults> searchMulti({
    required String query,
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.searchMulti,
      query: {
        'query': query,
        'page': '$page',
        'language': 'en-US',
        'include_adult': 'false',
      },
    );
    return PaginatedSearchResults.fromJson(response as Map<String, dynamic>);
  }
}
