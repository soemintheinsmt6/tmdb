import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb/core/theme/app_colors.dart';

/// List skeleton shown while a multi-search query is in flight. Mirrors the
/// layout of [SearchResultTile] so the swap is seamless.
class SearchResultsSkeleton extends StatelessWidget {
  const SearchResultsSkeleton({super.key, this.itemCount = 10});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.shimmerBase,
      highlightColor: colors.shimmerHighlight,
      child: ListView.builder(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: itemCount,
        itemBuilder: (_, __) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.shimmerBase,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.shimmerBase,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 120,
                        decoration: BoxDecoration(
                          color: colors.shimmerBase,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
