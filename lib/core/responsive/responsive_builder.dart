import 'package:flutter/material.dart';
import 'package:tmdb/core/responsive/app_breakpoints.dart';

enum ScreenTier { mobile, tablet }

/// Builds different widget trees based on the available width.
/// Two tiers only — mobile and tablet.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    this.mobile,
    this.tablet,
    this.builder,
  }) : assert(
         mobile != null || builder != null,
         'Provide at least mobile or builder.',
       );

  final Widget Function(BuildContext, BoxConstraints)? mobile;
  final Widget Function(BuildContext, BoxConstraints)? tablet;
  final Widget Function(BuildContext, BoxConstraints, ScreenTier)? builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final width = constraints.maxWidth;
        final tier = AppBreakpoints.isTablet(width)
            ? ScreenTier.tablet
            : ScreenTier.mobile;

        if (builder != null) return builder!(ctx, constraints, tier);

        return switch (tier) {
          ScreenTier.tablet => (tablet ?? mobile)!.call(ctx, constraints),
          ScreenTier.mobile => mobile!.call(ctx, constraints),
        };
      },
    );
  }
}

/// Centres content and caps it at [AppBreakpoints.maxContentWidth].
class CentredContentBox extends StatelessWidget {
  const CentredContentBox({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
