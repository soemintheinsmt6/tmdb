import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/core/sharing/media_share.dart';
import 'package:tmdb/shared/domain/media_type.dart';
import 'package:tmdb/shared/domain/shareable_media.dart';

void main() {
  group('tmdbUrl', () {
    test('builds the canonical movie URL', () {
      expect(
        tmdbUrl(MediaType.movie, 550),
        'https://www.themoviedb.org/movie/550',
      );
    });

    test('builds the canonical tv URL', () {
      expect(tmdbUrl(MediaType.tv, 1399), 'https://www.themoviedb.org/tv/1399');
    });
  });

  group('buildShareMessage', () {
    test('includes title, year, and the link', () {
      const media = ShareableMedia(
        mediaType: MediaType.movie,
        id: 550,
        title: 'Fight Club',
        year: '1999',
      );

      final message = buildShareMessage(media);

      expect(message, contains('Fight Club (1999)'));
      expect(message, contains('https://www.themoviedb.org/movie/550'));
    });

    test('omits the year when unknown', () {
      const media = ShareableMedia(
        mediaType: MediaType.tv,
        id: 1399,
        title: 'Game of Thrones',
      );

      final message = buildShareMessage(media);

      expect(message, startsWith('Game of Thrones'));
      expect(message, isNot(contains('(')));
      expect(message, contains('https://www.themoviedb.org/tv/1399'));
    });
  });
}
