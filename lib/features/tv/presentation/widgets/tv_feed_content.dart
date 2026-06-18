import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_feed_bloc/tv_feed_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_feed_bloc/tv_feed_event.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_feed_bloc/tv_feed_state.dart';
import 'package:tmdb/features/tv/presentation/screens/tv_category_screen.dart';
import 'package:tmdb/features/tv/presentation/screens/tv_detail/tv_detail_screen.dart';
import 'package:tmdb/shared/domain/poster_item.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';
import 'package:tmdb/shared/widgets/detail_cards.dart';
import 'package:tmdb/shared/widgets/featured_hero.dart';
import 'package:tmdb/shared/widgets/rail_feed_skeleton.dart';

/// The editorial series body: a trending hero over a vertical stack of TV
/// category rails. Mirrors the home layout for the TV vertical.
class TvFeedContent extends StatelessWidget {
  const TvFeedContent({super.key});

  void _open(BuildContext context, PosterItem item) => unawaited(
    pushView(context, TvDetailScreen(tvShowId: item.id, title: item.title)),
  );

  void _seeAll(BuildContext context, TvCategory category, String title) =>
      unawaited(
        pushView(context, TvCategoryScreen(category: category, title: title)),
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TvFeedBloc, TvFeedState>(
      builder: (context, state) {
        switch (state.status) {
          case TvFeedStatus.initial:
          case TvFeedStatus.loading:
            return const RailFeedSkeleton();
          case TvFeedStatus.error:
            return AppErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<TvFeedBloc>().add(const TvFeedRefreshed()),
            );
          case TvFeedStatus.loaded:
            return _buildLoaded(context, state);
        }
      },
    );
  }

  Widget _buildLoaded(BuildContext context, TvFeedState state) {
    final rails = <Widget>[];
    void addRail(String title, List<PosterItem> items, {VoidCallback? onSeeAll}) {
      if (items.isEmpty) return;
      rails
        ..add(const SizedBox(height: 24))
        ..add(
          DetailPosterRail(
            title: title,
            items: items,
            onTap: (item) => _open(context, item),
            onSeeAll: onSeeAll,
          ),
        );
    }

    // The hero already features trending[0]; the rail shows the rest.
    addRail(
      'Trending',
      state.trending.length > 1 ? state.trending.sublist(1) : const [],
    );
    addRail(
      'Popular',
      state.popular,
      onSeeAll: () => _seeAll(context, TvCategory.popular, 'Popular'),
    );
    addRail(
      'Top Rated',
      state.topRated,
      onSeeAll: () => _seeAll(context, TvCategory.topRated, 'Top Rated'),
    );
    addRail(
      'On The Air',
      state.onTheAir,
      onSeeAll: () => _seeAll(context, TvCategory.onTheAir, 'On The Air'),
    );
    addRail(
      'Airing Today',
      state.airingToday,
      onSeeAll: () => _seeAll(context, TvCategory.airingToday, 'Airing Today'),
    );

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<TvFeedBloc>().add(const TvFeedRefreshed()),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (state.trending.isNotEmpty)
            FeaturedHero(
              item: state.trending.first,
              onTap: () => _open(context, state.trending.first),
            ),
          ...rails,
        ],
      ),
    );
  }
}
