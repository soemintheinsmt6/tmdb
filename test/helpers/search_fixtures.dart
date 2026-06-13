import 'package:tmdb/features/search/domain/entities/paginated_search_results.dart';
import 'package:tmdb/features/search/domain/entities/search_result.dart';

/// Reusable builders. Every parameter has a sensible default so tests only
/// override the fields that matter to the assertion.
SearchResult buildSearchResult({
  int id = 603,
  SearchMediaType mediaType = SearchMediaType.movie,
  String title = 'The Matrix',
  String? imagePath = '/poster.jpg',
  String? backdropPath = '/backdrop.jpg',
  String? date = '1999-03-31',
  double voteAverage = 8.2,
  int voteCount = 24000,
  String knownForDepartment = '',
  String overview = 'A hacker learns the truth about his reality.',
}) {
  return SearchResult(
    id: id,
    mediaType: mediaType,
    title: title,
    imagePath: imagePath,
    backdropPath: backdropPath,
    date: date,
    voteAverage: voteAverage,
    voteCount: voteCount,
    knownForDepartment: knownForDepartment,
    overview: overview,
  );
}

PaginatedSearchResults buildPaginatedSearch({
  List<SearchResult>? results,
  int page = 1,
  int totalPages = 5,
  int totalResults = 100,
}) {
  return PaginatedSearchResults(
    results: results ?? [buildSearchResult()],
    page: page,
    totalPages: totalPages,
    totalResults: totalResults,
  );
}
