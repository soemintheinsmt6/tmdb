import 'package:equatable/equatable.dart';

/// A trailer / teaser / clip attached to a movie or TV show. The `/videos`
/// payload has the same shape for both `/movie/{id}/videos` and
/// `/tv/{id}/videos`. Shared by the movie and TV features.
class Video extends Equatable {
  const Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.official,
    required this.publishedAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String? ?? '',
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      site: json['site'] as String? ?? '',
      type: json['type'] as String? ?? '',
      official: (json['official'] as bool?) ?? false,
      publishedAt: json['published_at'] as String? ?? '',
    );
  }

  /// TMDB video id (a string, unlike most TMDB ids).
  final String id;

  /// Provider-specific id — the YouTube video id when [site] is `YouTube`.
  final String key;

  /// Human title, e.g. `"Official Trailer"`.
  final String name;

  /// Hosting site, e.g. `"YouTube"` or `"Vimeo"`.
  final String site;

  /// Video kind, e.g. `"Trailer"`, `"Teaser"`, `"Clip"`, `"Featurette"`.
  final String type;

  /// Whether the studio published it (vs. a fan upload).
  final bool official;

  /// ISO-8601 publish timestamp; `""` when unknown.
  final String publishedAt;

  /// True when this is a playable YouTube video.
  bool get isYouTube => site == 'YouTube' && key.isNotEmpty;

  /// Watch URL on YouTube, or `""` when this isn't a YouTube video.
  String get youtubeUrl =>
      isYouTube ? 'https://www.youtube.com/watch?v=$key' : '';

  /// 16:9-croppable preview image for the YouTube video, or `""` otherwise.
  String get thumbnailUrl =>
      isYouTube ? 'https://img.youtube.com/vi/$key/hqdefault.jpg' : '';

  @override
  List<Object?> get props => [id, key, name, site, type, official, publishedAt];
}

/// Ordering and selection helpers over a raw `/videos` result list.
extension VideoSelection on List<Video> {
  /// Relative priority of a video [type] for display — lower sorts first.
  /// Trailers lead, then teasers, then clips, then everything else.
  static int _typeRank(String type) {
    switch (type) {
      case 'Trailer':
        return 0;
      case 'Teaser':
        return 1;
      case 'Clip':
        return 2;
      case 'Featurette':
        return 3;
      case 'Behind the Scenes':
        return 4;
      default:
        return 5;
    }
  }

  /// Playable YouTube videos, sorted so the most trailer-like, most official,
  /// and most recent come first — the order used by both the rail and
  /// [bestTrailer].
  List<Video> get youTubeVideos {
    final videos = where((v) => v.isYouTube).toList()
      ..sort((a, b) {
        final byType = _typeRank(a.type).compareTo(_typeRank(b.type));
        if (byType != 0) return byType;
        // Official uploads before fan uploads.
        if (a.official != b.official) return a.official ? -1 : 1;
        // Newest first (ISO-8601 timestamps sort lexicographically).
        return b.publishedAt.compareTo(a.publishedAt);
      });
    return videos;
  }

  /// The single best video to surface behind a primary "play" affordance —
  /// the top-ranked YouTube video, or `null` when there are none.
  Video? get bestTrailer {
    final videos = youTubeVideos;
    return videos.isEmpty ? null : videos.first;
  }
}
