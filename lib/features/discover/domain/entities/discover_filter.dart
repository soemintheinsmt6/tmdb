import 'package:equatable/equatable.dart';
import 'package:tmdb/shared/domain/media_type.dart';

export 'package:tmdb/shared/domain/media_type.dart';

/// Sort options exposed by the discover screen. Each maps to a different TMDB
/// `sort_by` value per media type, since movies and TV use different date/title
/// field names.
enum DiscoverSort {
  popularityDesc('popularity.desc', 'popularity.desc', 'Popularity'),
  ratingDesc('vote_average.desc', 'vote_average.desc', 'Top rated'),
  releaseDesc('primary_release_date.desc', 'first_air_date.desc', 'Newest'),
  releaseAsc('primary_release_date.asc', 'first_air_date.asc', 'Oldest'),
  titleAsc('original_title.asc', 'name.asc', 'Title A–Z');

  const DiscoverSort(this._movieValue, this._tvValue, this.label);

  final String _movieValue;
  final String _tvValue;

  /// Human label for the chip.
  final String label;

  /// TMDB `sort_by` value for the given [mediaType].
  String valueFor(MediaType mediaType) =>
      mediaType == MediaType.movie ? _movieValue : _tvValue;
}

/// The set of `/discover/{movie,tv}` filters the user can configure. Immutable;
/// [copyWith] produces edited copies and [toQuery] renders the TMDB params for
/// the active [mediaType].
class DiscoverFilter extends Equatable {
  const DiscoverFilter({
    this.mediaType = MediaType.movie,
    this.genreIds = const {},
    this.sort = DiscoverSort.popularityDesc,
    this.minRating = 0,
    this.year,
  });

  /// Which vertical to browse. Drives both the endpoint and the query-param
  /// dialect (`primary_release_year` vs `first_air_date_year`, etc.).
  final MediaType mediaType;

  /// Selected genre ids (combined with AND, matching TMDB's comma semantics).
  /// Genre ids differ between movies and TV, so this is reset when [mediaType]
  /// switches.
  final Set<int> genreIds;
  final DiscoverSort sort;

  /// Minimum `vote_average` (0–10); `0` means no minimum.
  final double minRating;

  /// Release / first-air year, or `null` for any year.
  final int? year;

  DiscoverFilter copyWith({
    MediaType? mediaType,
    Set<int>? genreIds,
    DiscoverSort? sort,
    double? minRating,
    int? year,
    bool clearYear = false,
  }) {
    return DiscoverFilter(
      mediaType: mediaType ?? this.mediaType,
      genreIds: genreIds ?? this.genreIds,
      sort: sort ?? this.sort,
      minRating: minRating ?? this.minRating,
      year: clearYear ? null : (year ?? this.year),
    );
  }

  /// True when anything differs from the default (used to badge the filter
  /// button and decide whether the active-filter chips are shown). [mediaType]
  /// is not a facet — it's a top-level mode, not a filter.
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

  /// Renders the TMDB discover query params for [mediaType] (page/language/
  /// api_key are added by the data source / client).
  Map<String, String> toQuery() {
    return {
      'sort_by': sort.valueFor(mediaType),
      'include_adult': 'false',
      if (genreIds.isNotEmpty) 'with_genres': genreIds.join(','),
      if (minRating > 0) 'vote_average.gte': minRating.toString(),
      if (year != null)
        (mediaType == MediaType.movie
                ? 'primary_release_year'
                : 'first_air_date_year'):
            '$year',
      // When ranking by score, require a vote floor so a handful of perfect
      // votes on an obscure title don't dominate the results.
      if (sort == DiscoverSort.ratingDesc) 'vote_count.gte': '200',
    };
  }

  @override
  List<Object?> get props => [mediaType, genreIds, sort, minRating, year];
}
