import 'package:tmdb/features/search/domain/entities/search_result.dart';

/// Scopes a search to a media type. [all] uses `/search/multi` (mixed results);
/// the others hit the type-specific TMDB search endpoints so each filter
/// paginates through the full set of matches for that type.
enum SearchFilter { all, movie, tv, person }

extension SearchFilterX on SearchFilter {
  /// Short label for the filter chip.
  String get label => switch (this) {
    SearchFilter.all => 'All',
    SearchFilter.movie => 'Movies',
    SearchFilter.tv => 'TV',
    SearchFilter.person => 'People',
  };

  /// The result media type this filter scopes to, or `null` for [all] (mixed),
  /// where each row carries its own `media_type` from the API.
  SearchMediaType? get mediaType => switch (this) {
    SearchFilter.all => null,
    SearchFilter.movie => SearchMediaType.movie,
    SearchFilter.tv => SearchMediaType.tv,
    SearchFilter.person => SearchMediaType.person,
  };
}
