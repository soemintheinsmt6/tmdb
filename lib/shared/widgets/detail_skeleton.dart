import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb/core/theme/app_colors.dart';

/// Shimmer placeholder for a detail screen's body — everything below the
/// backdrop header: the poster + title summary, overview lines, and a rail.
/// Mirrors the loaded layout's structure (including the summary's upward
/// overlap into the header) so content arrives with no layout shift.
class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({super.key, this.horizontalPadding = 16});

  final double horizontalPadding;

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
          const SizedBox(height: 28),
          // A rail (heading + a row of poster cards).
          Padding(
            padding: EdgeInsets.only(left: horizontalPadding),
            child: box(150, 18, 6),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 195,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, __) => box(130, 195, 12),
            ),
          ),
        ],
      ),
    );
  }
}
