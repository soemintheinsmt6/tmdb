import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/core/responsive/app_breakpoints.dart';

void main() {
  group('AppBreakpoints.isMobile / isTablet', () {
    test('treats <600 as mobile', () {
      expect(AppBreakpoints.isMobile(599), isTrue);
      expect(AppBreakpoints.isTablet(599), isFalse);
    });

    test('treats exactly 600 as tablet (boundary inclusive)', () {
      expect(AppBreakpoints.isMobile(600), isFalse);
      expect(AppBreakpoints.isTablet(600), isTrue);
    });

    test('treats >600 as tablet', () {
      expect(AppBreakpoints.isMobile(900), isFalse);
      expect(AppBreakpoints.isTablet(900), isTrue);
    });
  });

  group('AppBreakpoints.posterGridColumns', () {
    test('returns 3 on mobile widths', () {
      expect(AppBreakpoints.posterGridColumns(360), 3);
      expect(AppBreakpoints.posterGridColumns(599), 3);
    });

    test('clamps to 4 just above the tablet threshold', () {
      // 600 / 180 = 3.33 → floor 3 → clamped up to 4.
      expect(AppBreakpoints.posterGridColumns(600), 4);
    });

    test('scales with width between the clamps', () {
      // 900 / 180 = 5.0 → floor 5 → 5.
      expect(AppBreakpoints.posterGridColumns(900), 5);
      // 1100 / 180 = 6.11 → floor 6 → 6.
      expect(AppBreakpoints.posterGridColumns(1100), 6);
    });

    test('clamps to 7 on very wide screens', () {
      // 2000 / 180 = 11.1 → clamped down to 7.
      expect(AppBreakpoints.posterGridColumns(2000), 7);
    });
  });

  group('AppBreakpoints.horizontalPadding', () {
    test('uses a fixed 16pt on mobile', () {
      expect(AppBreakpoints.horizontalPadding(360), 16);
      expect(AppBreakpoints.horizontalPadding(599), 16);
    });

    test('uses 4% of width on tablet', () {
      expect(AppBreakpoints.horizontalPadding(800), closeTo(32, 0.001));
      expect(AppBreakpoints.horizontalPadding(1200), closeTo(48, 0.001));
    });
  });

  group('AppBreakpoints.posterCardAspectRatio', () {
    test('is tighter on mobile to leave room for the title row', () {
      expect(AppBreakpoints.posterCardAspectRatio(360), 0.48);
    });

    test('is slightly wider on tablet', () {
      expect(AppBreakpoints.posterCardAspectRatio(800), 0.52);
    });
  });
}
