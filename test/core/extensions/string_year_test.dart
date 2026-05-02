import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/core/extensions/string_year.dart';

void main() {
  group('YearX.year', () {
    test('extracts the year prefix from an ISO date', () {
      expect('2024-08-21'.year, '2024');
      expect('1999-10-15'.year, '1999');
    });

    test('accepts a bare year string', () {
      expect('2024'.year, '2024');
    });

    test('returns null when the string is too short', () {
      expect(''.year, isNull);
      expect('19'.year, isNull);
    });

    test('returns null when the prefix is not numeric', () {
      expect('TBD-08-21'.year, isNull);
      expect('???? '.year, isNull);
    });
  });
}
