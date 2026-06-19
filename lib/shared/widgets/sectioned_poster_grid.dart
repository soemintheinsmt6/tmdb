import 'package:flutter/material.dart';

import 'package:tmdb/core/responsive/app_breakpoints.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/shared/domain/poster_item.dart';
import 'package:tmdb/shared/widgets/poster_card.dart';

/// Poster grid split into "Movies" and "TV Shows" sections, each under a
/// labelled header with a count. Used by the Library grid layout (favourites &
/// watchlist) to keep the two media types visually separated.
///
/// Each group is passed in pre-ordered by the caller's sort; an empty group is
/// skipped entirely (header and all). Mirrors [PosterGrid]'s sliver structure
/// and responsive column/aspect-ratio handling.
class SectionedPosterGrid extends StatelessWidget {
  const SectionedPosterGrid({
    super.key,
    required this.movies,
    required this.tvShows,
    required this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final List<PosterItem> movies;
  final List<PosterItem> tvShows;
  final void Function(PosterItem item) onTap;
  final EdgeInsets padding;

  static const _sectionGap = 28.0;
  static const _headerGap = 12.0;

  @override
  Widget build(BuildContext context) {
    final columns = context.posterGridColumns;
    final aspectRatio = context.posterCardAspectRatio;

    final slivers = <Widget>[];

    void addSection(String title, List<PosterItem> group) {
      if (group.isEmpty) return;
      // First section opens with the configured top inset; later ones get a
      // larger gap so the two groups read as clearly separate.
      final topGap = slivers.isEmpty ? padding.top : _sectionGap;
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              padding.left,
              topGap,
              padding.right,
              _headerGap,
            ),
            child: _SectionHeader(title: title, count: group.length),
          ),
        ),
      );
      slivers.add(
        SliverPadding(
          padding: EdgeInsets.only(left: padding.left, right: padding.right),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: aspectRatio,
            ),
            itemCount: group.length,
            itemBuilder: (_, index) {
              final item = group[index];
              return PosterCard(item: item, onTap: () => onTap(item));
            },
          ),
        ),
      );
    }

    addSection('Movies', movies);
    addSection('TV Shows', tvShows);
    slivers.add(SliverToBoxAdapter(child: SizedBox(height: padding.bottom)));

    return CustomScrollView(slivers: slivers);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        // Cyan accent bar — the app's TMDB-brand accent.
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.cyan,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTypography.subTitle),
        const SizedBox(width: 10),
        Text(
          '$count',
          style: AppTypography.bodyText.copyWith(color: colors.textMuted),
        ),
        const SizedBox(width: 12),
        // Hairline divider filling the rest of the row.
        Expanded(
          child: Container(
            height: 1,
            color: colors.textMuted.withValues(alpha: 0.25),
          ),
        ),
      ],
    );
  }
}
