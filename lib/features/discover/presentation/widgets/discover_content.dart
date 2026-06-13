import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/discover/presentation/bloc/discover_bloc.dart';
import 'package:tmdb/features/discover/presentation/bloc/discover_event.dart';
import 'package:tmdb/features/discover/presentation/bloc/discover_state.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_detail/movie_detail_screen.dart';
import 'package:tmdb/shared/domain/poster_item.dart';
import 'package:tmdb/shared/widgets/app_empty_view.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';
import 'package:tmdb/shared/widgets/poster_grid.dart';
import 'package:tmdb/shared/widgets/poster_grid_skeleton.dart';

/// Body of the discover screen: an infinite-scroll poster grid driven by the
/// active filter. Shared across form factors (the grid is responsive).
class DiscoverContent extends StatefulWidget {
  const DiscoverContent({super.key});

  @override
  State<DiscoverContent> createState() => _DiscoverContentState();
}

class _DiscoverContentState extends State<DiscoverContent> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 320) return;

    final state = context.read<DiscoverBloc>().state;
    if (state.status == DiscoverStatus.loaded &&
        state.hasMore &&
        !state.isLoadingMore) {
      context.read<DiscoverBloc>().add(const DiscoverLoadMore());
    }
  }

  Future<void> _onRefresh() async {
    context.read<DiscoverBloc>().add(const DiscoverRefreshed());
  }

  void _openDetail(PosterItem item) {
    unawaited(
      pushView(context, MovieDetailScreen(movieId: item.id, title: item.title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverBloc, DiscoverState>(
      builder: (context, state) {
        switch (state.status) {
          case DiscoverStatus.initial:
          case DiscoverStatus.loading:
            return const PosterGridSkeleton();
          case DiscoverStatus.error:
            return AppErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<DiscoverBloc>().add(const DiscoverRefreshed()),
            );
          case DiscoverStatus.loaded:
            if (state.movies.isEmpty) {
              return const AppEmptyView(
                message: 'No results. Try adjusting your filters.',
              );
            }
            return PosterGrid(
              scrollController: _scrollController,
              items: state.movies,
              onTap: _openDetail,
              onRefresh: _onRefresh,
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
            );
        }
      },
    );
  }
}
