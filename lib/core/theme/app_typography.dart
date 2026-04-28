import 'package:flutter/material.dart';

/// App typography scale. Styles intentionally have **no `color`** so that
/// `Theme.textTheme.apply(bodyColor:, displayColor:)` in [AppTheme] resolves
/// the right tone for the active brightness.
///
/// At call sites that need a non-default tone (secondary, muted, etc.),
/// use `style.copyWith(color: context.colors.textSecondary)`.
class AppTypography {
  AppTypography._();

  // ── Headings ──────────────────────────────────────────
  /// Large page titles — 28px · Bold
  static const TextStyle pageTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// Section headings, card headers — 22px · Semibold
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  /// Sub-section headings, dialog titles — 18px · Semibold
  static const TextStyle subTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ── Body ──────────────────────────────────────────────
  /// Primary body text — 16px · Regular
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Standard body / list items — 14px · Regular
  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── Supporting ────────────────────────────────────────
  /// Timestamps, meta labels, chip text — 12px · Regular
  static const TextStyle smallText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Badges, fine print — 10px · Regular
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.4,
  );

  // ── Interactive ───────────────────────────────────────
  /// Button label — 16px · Semibold
  static const TextStyle buttonLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );
}
