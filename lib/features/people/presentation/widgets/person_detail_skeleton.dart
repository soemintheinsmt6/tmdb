import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb/core/theme/app_colors.dart';

/// Shimmer placeholder for the person detail screen: profile photo + name and
/// vital-stat chips, a biography block, and the filmography rail. Mirrors the
/// loaded layout's structure so content arrives with no layout shift.
class PersonDetailSkeleton extends StatelessWidget {
  const PersonDetailSkeleton({super.key, this.horizontalPadding = 16});

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
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: profile photo + name, department, and vital-stat chips.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    box(120, 180, 12), // profile photo (2:3)
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          box(double.infinity, 22, 6), // name
                          const SizedBox(height: 8),
                          box(120, 12, 6), // known-for department
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              box(120, 14, 6), // birthday
                              box(80, 14, 6), // age
                              box(150, 14, 6), // place of birth
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Biography.
                box(110, 18, 6), // "Biography" heading
                const SizedBox(height: 12),
                box(double.infinity, 12, 6),
                const SizedBox(height: 8),
                box(double.infinity, 12, 6),
                const SizedBox(height: 8),
                box(double.infinity, 12, 6),
                const SizedBox(height: 8),
                box(double.infinity, 12, 6),
                const SizedBox(height: 8),
                box(180, 12, 6), // last, shorter line
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Filmography rail (heading + a row of poster cards with titles).
          Padding(
            padding: EdgeInsets.only(left: horizontalPadding),
            child: box(150, 18, 6),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  box(130, 195, 12), // poster
                  const SizedBox(height: 6),
                  box(90, 12, 6), // title
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
