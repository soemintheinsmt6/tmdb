import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb/core/theme/app_colors.dart';

/// List skeleton shown while a season's episodes load. Mirrors the layout of
/// [EpisodeTile] — a still on the left, then title / meta / overview lines — so
/// the swap into the real list is seamless.
class SeasonDetailSkeleton extends StatelessWidget {
  const SeasonDetailSkeleton({super.key, this.itemCount = 8});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => const _EpisodeTileSkeleton(),
    );
  }
}

class _EpisodeTileSkeleton extends StatelessWidget {
  const _EpisodeTileSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.shimmerBase,
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      // Shimmer sits inside the static card so the border doesn't shimmer; the
      // grey blocks below are masked by the gradient, gaps show the surface.
      child: Shimmer.fromColors(
        baseColor: colors.shimmerBase,
        highlightColor: colors.shimmerHighlight,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: Container(
                  width: 116,
                  constraints: const BoxConstraints(minHeight: 96),
                  color: colors.shimmerBase,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bar(160, 14),
                      const SizedBox(height: 8),
                      bar(110, 10),
                      const SizedBox(height: 10),
                      bar(double.infinity, 10),
                      const SizedBox(height: 6),
                      bar(220, 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
