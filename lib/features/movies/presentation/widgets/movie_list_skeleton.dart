import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb/core/responsive/app_breakpoints.dart';
import 'package:tmdb/core/theme/app_colors.dart';

/// Grid skeleton used while a movie list is loading.
class MovieListSkeleton extends StatelessWidget {
  const MovieListSkeleton({super.key, this.itemCount = 8});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final columns = context.posterGridColumns;
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.shimmerBase,
      highlightColor: colors.shimmerHighlight,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.55,
        ),
        itemCount: itemCount,
        itemBuilder: (_, __) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.shimmerBase,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: double.infinity,
                color: colors.shimmerBase,
              ),
              const SizedBox(height: 6),
              Container(height: 10, width: 60, color: colors.shimmerBase),
            ],
          );
        },
      ),
    );
  }
}
