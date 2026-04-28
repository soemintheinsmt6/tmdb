import 'package:flutter/material.dart';
import 'package:tmdb/core/theme/app_colors.dart';

/// Reusable decoration tokens.
class AppDecoration {
  AppDecoration._();

  /// Subtle shadow used on card-style containers.
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];

  /// Standard card decoration: surface background, 16px radius, subtle shadow.
  static BoxDecoration card(BuildContext context, {double radius = 16}) {
    return BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: cardShadow,
    );
  }
}
