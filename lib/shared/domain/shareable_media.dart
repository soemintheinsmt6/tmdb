import 'package:tmdb/shared/domain/media_type.dart';

/// The minimal data needed to share a title to the system share sheet.
class ShareableMedia {
  const ShareableMedia({
    required this.mediaType,
    required this.id,
    required this.title,
    this.year,
    this.backdropUrl,
  });

  final MediaType mediaType;
  final int id;
  final String title;
  final String? year;

  /// Fully-qualified backdrop image URL. Attached to the share when reachable;
  /// an empty/null value (or a failed fetch) falls back to text + link only.
  final String? backdropUrl;
}
