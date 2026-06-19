import 'package:equatable/equatable.dart';
import 'package:tmdb/features/search/domain/entities/search_result.dart';

/// One page of search results. Mirrors `PaginatedMovies`, but the `fromJson`
/// drops any entry that isn't a renderable media type (movie / TV / person) or
/// lacks a usable id — TMDB also returns `collection` rows the app has no detail
/// screen for.
///
/// [mediaType] is passed for the type-specific endpoints (`/search/movie` etc.),
/// whose rows lack a `media_type`; `/search/multi` leaves it null so each row's
/// own discriminator is used.
class PaginatedSearchResults extends Equatable {
  const PaginatedSearchResults({
    required this.results,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  factory PaginatedSearchResults.fromJson(
    Map<String, dynamic> json, {
    SearchMediaType? mediaType,
  }) {
    final results = ((json['results'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((e) => SearchResult.tryFromJson(e, mediaType: mediaType))
        .whereType<SearchResult>()
        .toList();

    return PaginatedSearchResults(
      results: results,
      page: (json['page'] as int?) ?? 1,
      totalPages: (json['total_pages'] as int?) ?? 1,
      totalResults: (json['total_results'] as int?) ?? results.length,
    );
  }

  final List<SearchResult> results;
  final int page;
  final int totalPages;
  final int totalResults;

  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [results, page, totalPages, totalResults];
}
