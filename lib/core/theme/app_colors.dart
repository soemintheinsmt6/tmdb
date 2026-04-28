import 'package:flutter/material.dart';

/// TMDB-inspired palette.
///
/// - Brand and semantic colors are static constants — identical in both
///   themes (cyan stays cyan whether the surface is dark or light).
/// - Surface, text, divider, and skeleton colors are *instance* fields on
///   this class, with two prebuilt instances [light] and [dark].
///
/// Resolve theme-dependent colors at the call site with `context.colors`:
///
/// ```dart
/// Container(color: context.colors.surface)
/// ```
class AppColors {
  // ── Brand (static — identical in light & dark) ────────
  /// TMDB navy — app bars, top of gradient.
  static const Color navy = Color(0xFF032541);
  static const Color navyDark = Color(0xFF021724);

  /// TMDB cyan — primary CTAs, active tabs, accent strips.
  static const Color cyan = Color(0xFF01B4E4);

  /// TMDB green — rating ring, secondary highlights.
  static const Color green = Color(0xFF90CEA1);
  static const Color greenDark = Color(0xFF1ED5A9);

  // ── Semantic (static) ─────────────────────────────────
  static const Color success = Color(0xFF21D07A);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Fixed neutrals (static) ───────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F7FA);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray500 = Color(0xFF9AA8B6);
  static const Color gray700 = Color(0xFF6B7C8E);
  static const Color gray900 = Color(0xFF111827);

  // ── Theme-dependent (instance fields) ─────────────────
  const AppColors._({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.divider,
    required this.border,
  });

  /// Page background.
  final Color background;

  /// Card / sheet background.
  final Color surface;

  /// Subtle surface for chips, list-row hover.
  final Color surfaceMuted;

  /// Primary text on [surface].
  final Color textPrimary;

  /// Secondary text (meta, captions).
  final Color textSecondary;

  /// Muted text (placeholders, disabled).
  final Color textMuted;

  /// Skeleton shimmer base.
  final Color shimmerBase;

  /// Skeleton shimmer highlight.
  final Color shimmerHighlight;

  /// Divider lines.
  final Color divider;

  /// Card / input borders.
  final Color border;

  // ── Prebuilt palettes ─────────────────────────────────
  static const AppColors dark = AppColors._(
    background: Color(0xFF0E1B2A),
    surface: Color(0xFF1A2A3A),
    surfaceMuted: Color(0xFF24384C),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFB6C2D2),
    textMuted: Color(0xFF7C8B9C),
    shimmerBase: Color(0xFF1F2F40),
    shimmerHighlight: Color(0xFF2C4257),
    divider: Color(0x1FFFFFFF),
    border: Color(0x33FFFFFF),
  );

  static const AppColors light = AppColors._(
    background: Color(0xFFF5F7FA),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEEF1F5),
    textPrimary: Color(0xFF0E1B2A),
    textSecondary: Color(0xFF4A5C72),
    textMuted: Color(0xFF8A99AC),
    shimmerBase: Color(0xFFE5E9EF),
    shimmerHighlight: Color(0xFFF3F5F8),
    divider: Color(0x14000000),
    border: Color(0x29000000),
  );

  /// Returns the palette matching [Theme.of(context).brightness].
  static AppColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}

/// Convenience accessor: `context.colors.surface`.
extension AppColorsContext on BuildContext {
  AppColors get colors => AppColors.of(this);
}
