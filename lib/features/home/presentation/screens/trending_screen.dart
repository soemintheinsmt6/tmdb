import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/home/domain/repositories/trending_repository.dart';
import 'package:tmdb/features/home/presentation/cubit/trending_list_cubit.dart';
import 'package:tmdb/features/home/presentation/cubit/trending_list_state.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_detail/movie_detail_screen.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/features/tv/presentation/screens/tv_detail/tv_detail_screen.dart';
import 'package:tmdb/injection_container.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';
import 'package:tmdb/shared/widgets/common/app_empty_view.dart';
import 'package:tmdb/shared/widgets/common/app_error_view.dart';
import 'package:tmdb/shared/widgets/poster/poster_grid.dart';
import 'package:tmdb/shared/widgets/skeletons/poster_grid_skeleton.dart';

/// Full, paginated grid of today's trending movies and TV — reached from the
/// home "Trending" rail's "See all".
class TrendingScreen extends StatelessWidget {
  const TrendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = TrendingListCubit(sl<TrendingRepository>());
        unawaited(cubit.load());
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(titleSpacing: 0, title: const Text('Trending')),
        body: const SafeArea(child: _TrendingGrid()),
      ),
    );
  }
}

class _TrendingGrid extends StatelessWidget {
  const _TrendingGrid();

  void _open(BuildContext context, PosterItem item) {
    final Widget screen = item is TvShow
        ? TvDetailScreen(tvShowId: item.id, title: item.title)
        : MovieDetailScreen(movieId: item.id, title: item.title);
    unawaited(pushView(context, screen));
  }

  /// Loads the next page as the grid nears its end. Returns false so the
  /// notification keeps bubbling.
  bool _maybeLoadMore(BuildContext context, ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.pixels >= metrics.maxScrollExtent - 320) {
      unawaited(context.read<TrendingListCubit>().loadMore());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrendingListCubit, TrendingListState>(
      builder: (context, state) {
        switch (state.status) {
          case TrendingListStatus.initial:
          case TrendingListStatus.loading:
            return const PosterGridSkeleton();
          case TrendingListStatus.error:
            return AppErrorView(
              message: state.message,
              onRetry: () => context.read<TrendingListCubit>().load(),
            );
          case TrendingListStatus.loaded:
            if (state.items.isEmpty) {
              return const AppEmptyView(message: 'Nothing to show');
            }
            return NotificationListener<ScrollNotification>(
              onNotification: (n) => _maybeLoadMore(context, n),
              child: PosterGrid(
                items: state.items,
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
      },
    );
  }
}
