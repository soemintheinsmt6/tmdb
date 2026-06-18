import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb/core/theme/app_colors.dart';

/// Loading placeholder for an editorial rail feed (home / series): a hero block
/// followed by a few rail rows, matching the loaded layout's rhythm.
class RailFeedSkeleton extends StatelessWidget {
  const RailFeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget box(double width, double height, [double radius = 12]) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.shimmerBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    Widget rail() => Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: box(150, 18, 6),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, __) => box(130, 200),
            ),
          ),
        ],
      ),
    );

    return Shimmer.fromColors(
      baseColor: colors.shimmerBase,
      highlightColor: colors.shimmerHighlight,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          AspectRatio(aspectRatio: 16 / 10, child: box(double.infinity, 0, 0)),
          rail(),
          rail(),
        ],
      ),
    );
  }
}
