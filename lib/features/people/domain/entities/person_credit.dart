import 'package:equatable/equatable.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/extensions/double_rating.dart';
import 'package:tmdb/core/extensions/string_year.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';

/// The kind of title a [PersonCredit] points to. `combined_credits` also
/// reports `person` entries (e.g. self appearances); those are dropped in the
/// data source, so [PersonCredit.mediaType] is nullable to signal "not a
/// routable title".
enum CreditMediaType { movie, tv }

/// One entry from `/person/{id}/combined_credits` — a movie or TV title the
/// person was credited in. Implements [PosterItem] so the shared poster widgets
/// (`DetailPosterRail`) render a filmography with no bespoke UI.
class PersonCredit extends Equatable implements PosterItem {
  const PersonCredit({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.role,
    required this.popularity,
    required this.mediaType,
  });

  factory PersonCredit.fromJson(Map<String, dynamic> json) {
    return PersonCredit(
      id: json['id'] as int,
      title: (json['title'] ?? json['name']) as String? ?? '',
      posterPath: json['poster_path'] as String?,
      releaseDate:
          (json['release_date'] ?? json['first_air_date']) as String? ?? '',
      voteAverage: ((json['vote_average'] as num?) ?? 0).toDouble(),
      voteCount: (json['vote_count'] as int?) ?? 0,
      role: (json['character'] ?? json['job']) as String? ?? '',
      popularity: ((json['popularity'] as num?) ?? 0).toDouble(),
      mediaType: _mediaTypeFrom(json['media_type'] as String?),
    );
  }

  static CreditMediaType? _mediaTypeFrom(String? raw) {
    return switch (raw) {
      'movie' => CreditMediaType.movie,
      'tv' => CreditMediaType.tv,
      _ => null,
    };
  }

  @override
  final int id;
  @override
  final String title;
  final String? posterPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;

  /// Character played (cast) — the `character` field from the credits payload.
  final String role;
  final double popularity;

  /// `null` for entries that aren't a routable movie or TV title.
  final CreditMediaType? mediaType;

  @override
  String posterUrl({String size = 'w500'}) =>
      ApiConstants.posterUrl(posterPath, size: size);

  /// Credits carry no backdrop; they only ever render in a poster rail, never
  /// as a hero. Satisfies [PosterItem] with an empty URL.
  @override
  String backdropUrl({String size = 'w1280'}) => '';

  /// [PosterItem] year — release / first-air year.
  @override
  String? get year => releaseDate.year;

  /// One-decimal score, e.g. `"7.5"`. `"NR"` when unrated.
  @override
  String get formattedRating => voteCount == 0 ? 'NR' : voteAverage.rating;

  @override
  List<Object?> get props => [
    id,
    title,
    posterPath,
    releaseDate,
    voteAverage,
    voteCount,
    role,
    popularity,
    mediaType,
  ];
}
