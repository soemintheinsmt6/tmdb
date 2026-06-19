import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/search/domain/entities/paginated_search_results.dart';
import 'package:tmdb/features/search/domain/entities/search_filter.dart';

abstract class SearchRepository {
  /// Searches within the scope of [filter] — `/search/multi` for
  /// [SearchFilter.all], otherwise the type-specific search endpoint.
  ResultFuture<PaginatedSearchResults> search({
    required String query,
    required SearchFilter filter,
    int page = 1,
  });
}
