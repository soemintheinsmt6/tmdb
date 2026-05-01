import 'package:flutter/material.dart';
import 'package:tmdb/core/responsive/app_breakpoints.dart';
import 'package:tmdb/features/movies/data/models/movie.dart';
import 'package:tmdb/features/movies/presentation/widgets/movie_card.dart';

/// Grid of [MovieCard]s with an optional trailing footer (load-more spinner).
class MovieGrid extends StatelessWidget {
  const MovieGrid({
    super.key,
    required this.movies,
    required this.onTap,
    this.scrollController,
    this.padding = const EdgeInsets.all(16),
    this.footer,
    this.onRefresh,
  });

  final List<Movie> movies;
  final void Function(Movie movie) onTap;
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
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: aspectRatio,
            ),
            itemCount: movies.length,
            itemBuilder: (_, index) {
              final movie = movies[index];
              return MovieCard(movie: movie, onTap: () => onTap(movie));
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
