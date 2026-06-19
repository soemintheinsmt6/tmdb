import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:tmdb/core/responsive/app_breakpoints.dart';
import 'package:tmdb/core/theme/app_colors.dart';

/// Loading placeholder for the collection screen's body — a couple of overview
/// lines over a responsive poster grid. Sits beneath the (hero-seeded) backdrop
/// header, so it shrink-wraps and only covers the content below it.
class CollectionSkeleton extends StatelessWidget {
  const CollectionSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final columns = context.posterGridColumns;
    final aspectRatio = context.posterCardAspectRatio;

    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.shimmerBase,
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return Shimmer.fromColors(
      baseColor: colors.shimmerBase,
      highlightColor: colors.shimmerHighlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bar(110, 16),
                const SizedBox(height: 10),
                bar(double.infinity, 11),
                const SizedBox(height: 6),
                bar(double.infinity, 11),
                const SizedBox(height: 6),
                bar(200, 11),
              ],
            ),
          ),
          GridView.builder(
            primary: false,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: aspectRatio,
            ),
            itemCount: itemCount,
            itemBuilder: (_, __) => DecoratedBox(
              decoration: BoxDecoration(
                color: colors.shimmerBase,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
