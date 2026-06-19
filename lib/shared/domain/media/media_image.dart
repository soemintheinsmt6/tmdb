import 'package:equatable/equatable.dart';
import 'package:tmdb/core/constants/api_constants.dart';

/// A still image (backdrop) for a movie or TV show, from the `/images`
/// endpoint. Shared by the movie and TV features.
///
/// Named [MediaImage] to avoid clashing with Flutter's `ImageInfo`.
class MediaImage extends Equatable {
  const MediaImage({
    required this.filePath,
    required this.aspectRatio,
    required this.width,
    required this.height,
  });

  factory MediaImage.fromJson(Map<String, dynamic> json) {
    return MediaImage(
      filePath: json['file_path'] as String? ?? '',
      aspectRatio: ((json['aspect_ratio'] as num?) ?? 16 / 9).toDouble(),
      width: (json['width'] as int?) ?? 0,
      height: (json['height'] as int?) ?? 0,
    );
  }

  final String filePath;
  final double aspectRatio;
  final int width;
  final int height;

  /// Backdrop image URL at the given [size] (e.g. `w780` for thumbnails,
  /// `w1280`/`original` for the full-screen viewer).
  String url({String size = 'w780'}) =>
      ApiConstants.backdropUrl(filePath, size: size);

  @override
  List<Object?> get props => [filePath, aspectRatio, width, height];
}
