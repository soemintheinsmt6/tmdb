import 'package:equatable/equatable.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/extensions/string_year.dart';
import 'package:tmdb/features/tv/domain/entities/episode.dart';

/// Full season detail from `/tv/{id}/season/{n}` — season metadata plus the
/// ordered list of [Episode]s.
class SeasonDetail extends Equatable {
  const SeasonDetail({
    required this.id,
    required this.seasonNumber,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.airDate,
    required this.episodes,
  });

  factory SeasonDetail.fromJson(Map<String, dynamic> json) {
    return SeasonDetail(
      id: (json['id'] as int?) ?? 0,
      seasonNumber: (json['season_number'] as int?) ?? 0,
      name: json['name'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      airDate: json['air_date'] as String? ?? '',
      episodes: ((json['episodes'] as List?) ?? const [])
          .map((e) => Episode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final int seasonNumber;
  final String name;
  final String overview;
  final String? posterPath;
  final String airDate;
  final List<Episode> episodes;

  String posterUrl({String size = 'w342'}) =>
      ApiConstants.posterUrl(posterPath, size: size);

  String? get airYear => airDate.year;

  @override
  List<Object?> get props => [
    id,
    seasonNumber,
    name,
    overview,
    posterPath,
    airDate,
    episodes,
  ];
}
