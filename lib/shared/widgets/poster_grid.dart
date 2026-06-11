import 'package:flutter/material.dart';
import 'package:tmdb/core/responsive/app_breakpoints.dart';
import 'package:tmdb/shared/domain/poster_item.dart';
import 'package:tmdb/shared/widgets/poster_card.dart';

/// Grid of [PosterCard]s with an optional trailing footer (load-more spinner).
/// Generic over [PosterItem] so movies and TV shows share one grid.
class PosterGrid extends StatelessWidget {
  const PosterGrid({
    super.key,
    required this.items,
    required this.onTap,
    this.scrollController,
    this.padding = const EdgeInsets.all(16),
    this.footer,
    this.onRefresh,
  });

  final List<PosterItem> items;
  final void Function(PosterItem item) onTap;
  final ScrollController? scrollController;
  final EdgeInsets padding;
  final Widget? footer;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final columns = context.posterGridColumns;
    final aspectRatio = context.posterCardAspectRatio;

    final grid = CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: padding,
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: aspectRatio,
            ),
            itemCount: items.length,
            itemBuilder: (_, index) {
              final item = items[index];
              return PosterCard(item: item, onTap: () => onTap(item));
            },
          ),
        ),
        if (footer != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: footer,
            ),
          ),
      ],
    );

    if (onRefresh == null) return grid;
    return RefreshIndicator(onRefresh: onRefresh!, child: grid);
  }
}
