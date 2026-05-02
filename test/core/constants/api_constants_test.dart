import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/core/constants/api_constants.dart';

void main() {
  group('ApiConstants.posterUrl', () {
    test('returns an empty string when path is null', () {
      expect(ApiConstants.posterUrl(null), '');
    });

    test('returns an empty string when path is empty', () {
      expect(ApiConstants.posterUrl(''), '');
    });

    test('joins base URL, default size, and path', () {
      expect(
        ApiConstants.posterUrl('/poster.jpg'),
        'https://image.tmdb.org/t/p/w500/poster.jpg',
      );
    });

    test('honours the size override', () {
      expect(
        ApiConstants.posterUrl('/p.jpg', size: 'w185'),
        'https://image.tmdb.org/t/p/w185/p.jpg',
      );
    });
  });

  group('ApiConstants.backdropUrl', () {
    test('null and empty paths produce empty strings', () {
      expect(ApiConstants.backdropUrl(null), '');
      expect(ApiConstants.backdropUrl(''), '');
    });

    test('default size is w1280', () {
      expect(
        ApiConstants.backdropUrl('/b.jpg'),
        'https://image.tmdb.org/t/p/w1280/b.jpg',
      );
    });

    test('size override applies', () {
      expect(
        ApiConstants.backdropUrl('/b.jpg', size: 'original'),
        'https://image.tmdb.org/t/p/original/b.jpg',
      );
    });
  });

  group('ApiConstants.profileUrl', () {
    test('null and empty paths produce empty strings', () {
      expect(ApiConstants.profileUrl(null), '');
      expect(ApiConstants.profileUrl(''), '');
    });

    test('default size is w185', () {
      expect(
        ApiConstants.profileUrl('/p.jpg'),
        'https://image.tmdb.org/t/p/w185/p.jpg',
      );
    });
  });

  group('ApiConstants endpoint helpers', () {
    test('movieDetail interpolates the id', () {
      expect(ApiConstants.movieDetail(550), '/movie/550');
    });

    test('movieCredits and movieRecommendations interpolate the id', () {
      expect(ApiConstants.movieCredits(42), '/movie/42/credits');
      expect(ApiConstants.movieRecommendations(42), '/movie/42/recommendations');
    });
  });
}
