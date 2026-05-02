import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/core/extensions/double_rating.dart';

void main() {
  group('RatingX.rating', () {
    test('rounds to one decimal', () {
      expect(7.4567.rating, '7.5');
      expect(7.44.rating, '7.4');
    });

    test('keeps a trailing zero for whole numbers', () {
      expect(8.0.rating, '8.0');
      expect(0.0.rating, '0.0');
    });

    test('handles the 10.0 ceiling', () {
      expect(10.0.rating, '10.0');
    });
  });

  group('RatingX.ratingPercent', () {
    test('renders as `xx%`', () {
      expect(7.4.ratingPercent, '74%');
    });

    test('rounds to the nearest integer', () {
      expect(7.45.ratingPercent, '75%');
      expect(7.44.ratingPercent, '74%');
    });

    test('handles zero', () {
      expect(0.0.ratingPercent, '0%');
    });
  });
}
