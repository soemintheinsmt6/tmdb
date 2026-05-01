import 'package:flutter/material.dart';

/// Screen-width breakpoints. Two tiers only — mobile and tablet.
class AppBreakpoints {
  AppBreakpoints._();

  /// Width at which the layout switches from mobile to tablet.
  static const double mobile = 600;

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile;

  /// Max content width for narrow forms on wide screens.
  static const double maxContentWidth = 480;

  /// Horizontal padding — tighter on phones, generous on tablets.
  static double horizontalPadding(double width) {
    if (isTablet(width)) return width * 0.08;
    return 16;
  }

  /// Number of poster grid columns for the current width.
  static int posterGridColumns(double width) {
    if (isTablet(width)) return 4;
    return 3;
  }

  /// Card aspect ratio (width / height) tuned to leave room for the
  /// 2:3 poster plus title + year text below.
  static double posterCardAspectRatio(double width) {
    if (isTablet(width)) return 0.55;
    return 0.5;
  }
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isMobile => AppBreakpoints.isMobile(screenWidth);
  bool get isTablet => AppBreakpoints.isTablet(screenWidth);

  double get horizontalPadding => AppBreakpoints.horizontalPadding(screenWidth);
  int get posterGridColumns => AppBreakpoints.posterGridColumns(screenWidth);
  double get posterCardAspectRatio =>
      AppBreakpoints.posterCardAspectRatio(screenWidth);
}
