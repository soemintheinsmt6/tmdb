import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/core/extensions/int_runtime.dart';

void main() {
  group('RuntimeX.runtime', () {
    test('formats hours and minutes', () {
      expect(142.runtime, '2h 22m');
      expect(60.runtime, '1h');
      expect(125.runtime, '2h 5m');
    });

    test('formats minutes-only when under an hour', () {
      expect(42.runtime, '42m');
      expect(1.runtime, '1m');
    });

    test('returns "—" for zero or negative runtimes', () {
      expect(0.runtime, '—');
      expect((-1).runtime, '—');
    });

    test('drops the minutes segment on round hours', () {
      expect(120.runtime, '2h');
      expect(180.runtime, '3h');
    });
  });
}
