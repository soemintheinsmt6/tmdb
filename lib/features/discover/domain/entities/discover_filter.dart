import 'package:equatable/equatable.dart';

/// Sort options exposed by the discover screen, mapped to TMDB `sort_by` values.
enum DiscoverSort {
  popularityDesc('popularity.desc', 'Popularity'),
  ratingDesc('vote_average.desc', 'Top rated'),
  releaseDesc('primary_release_date.desc', 'Newest'),
  releaseAsc('primary_release_date.asc', 'Oldest'),
  titleAsc('original_title.asc', 'Title A–Z');

  const DiscoverSort(this.value, this.label);

  /// TMDB `sort_by` query value.
  final String value;

  /// Human label for the chip.
  final String label;
}

/// The set of `/discover/movie` filters the user can configure. Immutable;
/// [copyWith] produces edited copies and [toQuery] renders the TMDB params.
class DiscoverFilter extends Equatable {
  const DiscoverFilter({
    this.genreIds = const {},
    this.sort = DiscoverSort.popularityDesc,
    this.minRating = 0,
    this.year,
  });

  /// Selected genre ids (combined with AND, matching TMDB's comma semantics).
  final Set<int> genreIds;
  final DiscoverSort sort;

  /// Minimum `vote_average` (0–10); `0` means no minimum.
  final double minRating;

  /// `primary_release_year`, or `null` for any year.
  final int? year;

  DiscoverFilter copyWith({
    Set<int>? genreIds,
    DiscoverSort? sort,
    double? minRating,
    int? year,
    bool clearYear = false,
  }) {
    return DiscoverFilter(
      genreIds: genreIds ?? this.genreIds,
      sort: sort ?? this.sort,
      minRating: minRating ?? this.minRating,
      year: clearYear ? null : (year ?? this.year),
    );
  }

  /// True when anything differs from the default (used to badge the filter
  /// button and decide whether a "clear" affordance is shown).
  bool get isActive =>
      genreIds.isNotEmpty ||
      minRating > 0 ||
      year != null ||
      sort != DiscoverSort.popularityDesc;

  /// Count of active facets, for the filter button badge.
  int get activeCount =>
      (genreIds.isNotEmpty ? 1 : 0) +
      (minRating > 0 ? 1 : 0) +
      (year != null ? 1 : 0) +
      (sort != DiscoverSort.popularityDesc ? 1 : 0);

  /// Renders the TMDB `/discover/movie` query params (page/language/api_key are
  /// added by the data source / client).
  Map<String, String> toQuery() {
    return {
      'sort_by': sort.value,
      'include_adult': 'false',
      if (genreIds.isNotEmpty) 'with_genres': genreIds.join(','),
      if (minRating > 0) 'vote_average.gte': minRating.toString(),
      if (year != null) 'primary_release_year': '$year',
      // When ranking by score, require a vote floor so a handful of perfect
      // votes on an obscure title don't dominate the results.
      if (sort == DiscoverSort.ratingDesc) 'vote_count.gte': '200',
    };
  }

  @override
  List<Object?> get props => [genreIds, sort, minRating, year];
}
