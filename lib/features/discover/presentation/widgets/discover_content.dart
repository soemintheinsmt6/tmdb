import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/discover/presentation/bloc/discover_bloc.dart';
import 'package:tmdb/features/discover/presentation/bloc/discover_event.dart';
import 'package:tmdb/features/discover/presentation/bloc/discover_state.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_detail/movie_detail_screen.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/features/tv/presentation/screens/tv_detail/tv_detail_screen.dart';
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
  /// Drives the poster grid. We prefer the ambient [PrimaryScrollController]
  /// (the active tab's controller, supplied by `RootScreen`) so an iOS
  /// status-bar tap scrolls this list to the top. [_ownedController] is a
  /// fallback used only when no primary is available (e.g. widget tests pumped
  /// without a route); we never dispose a controller we don't own.
  ScrollController? _scrollController;
  ScrollController? _ownedController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller =
        PrimaryScrollController.maybeOf(context) ??
        (_ownedController ??= ScrollController());
    if (identical(controller, _scrollController)) return;
    _scrollController?.removeListener(_onScroll);
    _scrollController = controller..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _ownedController?.dispose();
    super.dispose();
  }

  void _onScroll() {
    final controller = _scrollController;
    if (controller == null || !controller.hasClients) return;
    final position = controller.position;
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
    final Widget screen = item is TvShow
        ? TvDetailScreen(tvShowId: item.id, title: item.title)
        : MovieDetailScreen(movieId: item.id, title: item.title);
    unawaited(pushView(context, screen));
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
            if (state.items.isEmpty) {
              return const AppEmptyView(
                message: 'No results. Try adjusting your filters.',
              );
            }
            return PosterGrid(
              scrollController: _scrollController,
              items: state.items,
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
