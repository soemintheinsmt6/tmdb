import 'package:flutter/material.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';

const Map<MovieCategory, String> kCategoryLabels = {
  MovieCategory.popular: 'Popular',
  MovieCategory.nowPlaying: 'Now Playing',
  MovieCategory.topRated: 'Top Rated',
  MovieCategory.upcoming: 'Upcoming',
};

/// Horizontal scrolling tab bar of [MovieCategory]s.
class CategoryTabBar extends StatelessWidget {
  const CategoryTabBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TabController controller;
  final ValueChanged<MovieCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final categories = MovieCategory.values;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.divider, width: 1),
        ),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: (index) => onChanged(categories[index]),
        tabs: [
          for (final c in categories)
            Tab(text: kCategoryLabels[c], height: 44),
        ],
      ),
    );
  }
}
