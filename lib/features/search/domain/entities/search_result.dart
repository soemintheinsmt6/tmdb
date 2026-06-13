import 'package:equatable/equatable.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/extensions/double_rating.dart';
import 'package:tmdb/core/extensions/string_year.dart';

/// The kind of entity a multi-search row points to. Mirrors the `media_type`
/// discriminator TMDB tags onto every `/search/multi` result.
enum SearchMediaType { movie, tv, person }

/// Maps TMDB's `media_type` string to a [SearchMediaType], or `null` for kinds
/// the app does not render (e.g. `collection`).
SearchMediaType? searchMediaTypeFromString(String? raw) {
  return switch (raw) {
    'movie' => SearchMediaType.movie,
    'tv' => SearchMediaType.tv,
    'person' => SearchMediaType.person,
    _ => null,
  };
}

/// A single `/search/multi` result. TMDB returns movies, TV shows and people in
/// one mixed list, each tagged with a `media_type`. This unifies the three
/// shapes into one row model so the search UI can render and route them
/// uniformly.
///
/// Unlike `Movie` / `TvShow` it deliberately does **not** implement
/// `PosterItem`: people have neither a rating nor a year, so [formattedRating]
/// and [year] are nullable and callers hide those affordances when absent.
class SearchResult extends Equatable {
  const SearchResult({
    required this.id,
    required this.mediaType,
    required this.title,
    required this.imagePath,
    required this.backdropPath,
    required this.date,
    required this.voteAverage,
    required this.voteCount,
    required this.knownForDepartment,
    required this.overview,
  });

  /// Builds a [SearchResult] from one `/search/multi` entry, or `null` when the
  /// entry is a media type the app does not render (e.g. `collection`) or lacks
  /// a usable integer id. Parsing the page filters these out via
  /// `PaginatedSearchResults.fromJson`.
  static SearchResult? tryFromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final mediaType = searchMediaTypeFromString(json['media_type'] as String?);
    if (id is! int || mediaType == null) return null;

    return SearchResult(
      id: id,
      mediaType: mediaType,
      // Movies expose `title`; TV shows and people expose `name`.
      title: (json['title'] ?? json['name']) as String? ?? '',
      // Movies / TV carry `poster_path`; people carry `profile_path`.
      imagePath: (json['poster_path'] ?? json['profile_path']) as String?,
      backdropPath: json['backdrop_path'] as String?,
      date: (json['release_date'] ?? json['first_air_date']) as String?,
      voteAverage: ((json['vote_average'] as num?) ?? 0).toDouble(),
      voteCount: (json['vote_count'] as int?) ?? 0,
      knownForDepartment: json['known_for_department'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
    );
  }

  final int id;
  final SearchMediaType mediaType;
  final String title;
  final String? imagePath;
  final String? backdropPath;

  /// Release / first-air date for titles (`null` for people and undated titles).
  final String? date;
  final double voteAverage;
  final int voteCount;

  /// Primary department for people (e.g. `"Acting"`); empty for titles.
  final String knownForDepartment;
  final String overview;

  /// Fully-qualified image URL — poster art for titles, profile shot for
  /// people — or `''` when there is none.
  String imageUrl({String size = 'w185'}) {
    return mediaType == SearchMediaType.person
        ? ApiConstants.profileUrl(imagePath, size: size)
        : ApiConstants.posterUrl(imagePath, size: size);
  }

  /// Release / first-air year for titles, or `null` for people and undated
  /// titles.
  String? get year => date?.year;

  /// One-decimal score for titles (e.g. `"7.5"`), or `null` for people and
  /// unrated titles — callers hide the rating affordance when this is `null`.
  String? get formattedRating {
    if (mediaType == SearchMediaType.person || voteCount == 0) return null;
    return voteAverage.rating;
  }

  /// Short human label for the media type, e.g. `"Movie"`.
  String get mediaTypeLabel => switch (mediaType) {
    SearchMediaType.movie => 'Movie',
    SearchMediaType.tv => 'TV',
    SearchMediaType.person => 'Person',
  };

  @override
  List<Object?> get props => [
    id,
    mediaType,
    title,
    imagePath,
    backdropPath,
    date,
    voteAverage,
    voteCount,
    knownForDepartment,
    overview,
  ];
}
