import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_event.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_state.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_detail/movie_detail_screen.dart';
import 'package:tmdb/injection_container.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';
import 'package:tmdb/shared/widgets/common/app_empty_view.dart';
import 'package:tmdb/shared/widgets/common/app_error_view.dart';
import 'package:tmdb/shared/widgets/poster/poster_grid.dart';
import 'package:tmdb/shared/widgets/skeletons/poster_grid_skeleton.dart';

/// Full, paginated grid for a single movie category — reached from a home rail's
/// "See all". Reuses [MovieListBloc]'s infinite-scroll loading.
class MovieCategoryScreen extends StatelessWidget {
  const MovieCategoryScreen({
    super.key,
    required this.category,
    required this.title,
  });

  final MovieCategory category;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MovieListBloc(
        repository: sl<MovieRepository>(),
        initialCategory: category,
      ),
      child: Scaffold(
        appBar: AppBar(titleSpacing: 0, title: Text(title)),
        body: SafeArea(child: _MovieCategoryGrid(category: category)),
      ),
    );
  }
}

class _MovieCategoryGrid extends StatelessWidget {
  const _MovieCategoryGrid({required this.category});

  final MovieCategory category;

  void _open(BuildContext context, PosterItem item) => unawaited(
    pushView(context, MovieDetailScreen(movieId: item.id, title: item.title)),
  );

  /// Loads the next page as the grid nears its end. Returns false so the
  /// notification keeps bubbling.
  bool _maybeLoadMore(BuildContext context, ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.pixels < metrics.maxScrollExtent - 320) return false;
    final state = context.read<MovieListBloc>().state;
    if (state is MovieListLoaded && state.hasMore && !state.isLoadingMore) {
      context.read<MovieListBloc>().add(const MovieListLoadMore());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieListBloc, MovieListState>(
      builder: (context, state) {
        if (state is MovieListInitial || state is MovieListLoading) {
          return const PosterGridSkeleton();
        }
        if (state is MovieListError) {
          return AppErrorView(
            message: state.message,
            onRetry: () => context.read<MovieListBloc>().add(
              MovieListCategoryChanged(category),
            ),
          );
        }
        if (state is MovieListLoaded) {
          if (state.movies.isEmpty) {
            return const AppEmptyView(message: 'Nothing to show');
          }
          // No explicit scroll controller: this keeps the grid the route's
          // primary scroll view, so an iOS status-bar tap scrolls it to top.
          // Pagination is driven by scroll notifications instead.
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) =>
                _maybeLoadMore(context, notification),
            child: PosterGrid(
              items: state.movies,
              onTap: (item) => _open(context, item),
              footer: state.isLoadingMore
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.cyan,
                        ),
                      ),
                    )
                  : null,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
