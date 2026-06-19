import 'package:equatable/equatable.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/extensions/string_year.dart';

/// One season summary, parsed from a TV show's `/tv/{id}` payload (its
/// `seasons` array). The episode list is fetched separately as a [SeasonDetail].
class Season extends Equatable {
  const Season({
    required this.id,
    required this.seasonNumber,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.airDate,
    required this.episodeCount,
    required this.voteAverage,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: (json['id'] as int?) ?? 0,
      seasonNumber: (json['season_number'] as int?) ?? 0,
      name: json['name'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      airDate: json['air_date'] as String? ?? '',
      episodeCount: (json['episode_count'] as int?) ?? 0,
      voteAverage: ((json['vote_average'] as num?) ?? 0).toDouble(),
    );
  }

  final int id;
  final int seasonNumber;
  final String name;
  final String overview;
  final String? posterPath;
  final String airDate;
  final int episodeCount;
  final double voteAverage;

  String posterUrl({String size = 'w342'}) =>
      ApiConstants.posterUrl(posterPath, size: size);

  String? get airYear => airDate.year;

  /// e.g. `"8 Episodes"` / `"1 Episode"`; `""` when unknown.
  String get episodeCountLabel => episodeCount <= 0
      ? ''
      : '$episodeCount ${episodeCount == 1 ? 'Episode' : 'Episodes'}';

  @override
  List<Object?> get props => [
    id,
    seasonNumber,
    name,
    overview,
    posterPath,
    airDate,
    episodeCount,
    voteAverage,
  ];
}
