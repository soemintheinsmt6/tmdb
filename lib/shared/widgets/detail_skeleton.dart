import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb/core/theme/app_colors.dart';

/// Shimmer placeholder for a detail screen's body: the poster + title summary,
/// overview lines, and a rail. Mirrors the loaded layout's structure (including
/// the summary's upward overlap into the header) so content arrives with no
/// layout shift.
///
/// When [includeBackdrop] is true the skeleton also draws a backdrop placeholder
/// at the top, in the same shimmer pass as the body. Screens enable this when
/// they have no real backdrop (or hero) to show during loading, so the top of
/// the screen shimmers as one piece instead of leaving an inert, flat header
/// block above the summary.
class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({
    super.key,
    this.horizontalPadding = 16,
    this.includeBackdrop = false,
  });

  final double horizontalPadding;
  final bool includeBackdrop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget box(double width, double height, [double radius = 8]) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.shimmerBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    return Shimmer.fromColors(
      baseColor: colors.shimmerBase,
      highlightColor: colors.shimmerHighlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-bleed backdrop placeholder, matching DetailHeader's 16:9. The
          // summary below overlaps its bottom edge (Transform.translate), so the
          // two shimmer as one continuous surface.
          if (includeBackdrop)
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(color: Colors.transparent),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary row, pulled up to overlap the header to match the
                // loaded layout's Transform.translate(0, -40).
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      box(120, 180, 12), // poster
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            box(double.infinity, 22, 6), // title
                            const SizedBox(height: 8),
                            box(140, 12, 6), // tagline
                            const SizedBox(height: 16),
                            box(110, 16, 6), // rating stars
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                box(72, 22, 999),
                                const SizedBox(width: 8),
                                box(72, 22, 999),
                              ],
                            ), // meta chips
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                box(60, 26, 999),
                                const SizedBox(width: 6),
                                box(80, 26, 999),
                              ],
                            ), // genres
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                box(100, 16, 6), // "Overview" heading
                const SizedBox(height: 12),
                box(double.infinity, 12, 6),
                const SizedBox(height: 8),
                box(double.infinity, 12, 6),
                const SizedBox(height: 8),
                box(double.infinity, 12, 6),
                const SizedBox(height: 8),
                box(200, 12, 6), // last, shorter line
              ],
            ),
          ),
        ],
      ),
    );
  }
}
