import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:tmdb/shared/domain/media_type.dart';
import 'package:tmdb/shared/domain/shareable_media.dart';

/// Canonical public TMDB URL for a title.
String tmdbUrl(MediaType type, int id) {
  final path = type == MediaType.movie ? 'movie' : 'tv';
  return 'https://www.themoviedb.org/$path/$id';
}

/// The text body shared for [media] — title, year (when known), and the link.
String buildShareMessage(ShareableMedia media) {
  final year = media.year != null ? ' (${media.year})' : '';
  return '${media.title}$year\n\n${tmdbUrl(media.mediaType, media.id)}';
}

/// Opens the system share sheet for [media]. Attaches the backdrop image when
/// it can be fetched quickly; otherwise shares text + link only.
Future<void> shareMedia(ShareableMedia media) async {
  final text = buildShareMessage(media);
  final imagePath = await _cacheBackdrop(media);
  await SharePlus.instance.share(
    ShareParams(
      text: text,
      subject: media.title,
      files: imagePath != null ? [XFile(imagePath)] : null,
    ),
  );
}

/// Best-effort: downloads the backdrop to a temp file and returns its path, or
/// `null` when there's no backdrop or the fetch fails / times out.
Future<String?> _cacheBackdrop(ShareableMedia media) async {
  final url = media.backdropUrl;
  if (url == null || url.isEmpty) return null;
  try {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 4));
    if (response.statusCode != 200) return null;
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/share_${media.mediaType.name}_${media.id}.jpg',
    );
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  } catch (_) {
    return null;
  }
}
