import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/search/domain/entities/paginated_search_results.dart';

abstract class SearchRepository {
  /// Searches movies, TV shows and people in one call via `/search/multi`.
  ResultFuture<PaginatedSearchResults> searchMulti({
    required String query,
    int page = 1,
  });
}
