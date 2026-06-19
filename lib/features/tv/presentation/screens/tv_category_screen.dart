import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_list_bloc/tv_list_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_list_bloc/tv_list_event.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_list_bloc/tv_list_state.dart';
import 'package:tmdb/features/tv/presentation/screens/tv_detail/tv_detail_screen.dart';
import 'package:tmdb/injection_container.dart';
import 'package:tmdb/shared/domain/poster_item.dart';
import 'package:tmdb/shared/widgets/app_empty_view.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';
import 'package:tmdb/shared/widgets/poster_grid.dart';
import 'package:tmdb/shared/widgets/poster_grid_skeleton.dart';

/// Full, paginated grid for a single TV category — reached from a rail's
/// "See all". Reuses [TvListBloc]'s infinite-scroll loading.
class TvCategoryScreen extends StatelessWidget {
  const TvCategoryScreen({
    super.key,
    required this.category,
    required this.title,
  });

  final TvCategory category;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TvListBloc(repository: sl<TvRepository>(), initialCategory: category),
      child: Scaffold(
        appBar: AppBar(titleSpacing: 0, title: Text(title)),
        body: SafeArea(child: _TvCategoryGrid(category: category)),
      ),
    );
  }
}

class _TvCategoryGrid extends StatelessWidget {
  const _TvCategoryGrid({required this.category});

  final TvCategory category;

  void _open(BuildContext context, PosterItem item) => unawaited(
    pushView(context, TvDetailScreen(tvShowId: item.id, title: item.title)),
  );

  /// Loads the next page as the grid nears its end. Returns false so the
  /// notification keeps bubbling.
  bool _maybeLoadMore(BuildContext context, ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.pixels < metrics.maxScrollExtent - 320) return false;
    final state = context.read<TvListBloc>().state;
    if (state is TvListLoaded && state.hasMore && !state.isLoadingMore) {
      context.read<TvListBloc>().add(const TvListLoadMore());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TvListBloc, TvListState>(
      builder: (context, state) {
        if (state is TvListInitial || state is TvListLoading) {
          return const PosterGridSkeleton();
        }
        if (state is TvListError) {
          return AppErrorView(
            message: state.message,
            onRetry: () =>
                context.read<TvListBloc>().add(TvListCategoryChanged(category)),
          );
        }
        if (state is TvListLoaded) {
          if (state.shows.isEmpty) {
            return const AppEmptyView(message: 'Nothing to show');
          }
          // No explicit scroll controller: this keeps the grid the route's
          // primary scroll view, so an iOS status-bar tap scrolls it to top.
          // Pagination is driven by scroll notifications instead.
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) =>
                _maybeLoadMore(context, notification),
            child: PosterGrid(
              items: state.shows,
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
