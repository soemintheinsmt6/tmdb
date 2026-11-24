import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_feed_bloc/tv_feed_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_feed_bloc/tv_feed_event.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_feed_bloc/tv_feed_state.dart';
import 'package:tmdb/features/tv/presentation/screens/tv_category_screen.dart';
import 'package:tmdb/features/tv/presentation/screens/tv_detail/tv_detail_screen.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';
import 'package:tmdb/shared/widgets/common/fade_slide_in.dart';
import 'package:tmdb/shared/widgets/detail/detail_cards.dart';
import 'package:tmdb/shared/widgets/feed/featured_carousel.dart';
import 'package:tmdb/shared/widgets/feed/feed_state_switcher.dart';

/// The editorial series body: a trending hero over a vertical stack of TV
/// category rails. Mirrors the home layout for the TV vertical.
class TvFeedContent extends StatelessWidget {
  const TvFeedContent({super.key});

  void _open(BuildContext context, PosterItem item) => unawaited(
    pushView(context, TvDetailScreen(tvShowId: item.id, title: item.title)),
  );

  /// Route-unique hero tag for a featured slide, prefixed so the series and
  /// home carousels never collide while both are alive in the IndexedStack.
  Object _heroTag(PosterItem item) => 'series-featured-tv-${item.id}';

  /// Opens a featured (carousel) item with a shared backdrop hero transition,
  /// seeding the backdrop so the detail header matches during the flight.
  void _openFeatured(BuildContext context, PosterItem item) => unawaited(
    pushView(
      context,
      TvDetailScreen(
        tvShowId: item.id,
        title: item.title,
        heroTag: _heroTag(item),
        backdropPath: item is TvShow ? item.backdropPath : null,
      ),
    ),
  );

  void _seeAll(BuildContext context, TvCategory category, String title) =>
      unawaited(
        pushView(context, TvCategoryScreen(category: category, title: title)),
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TvFeedBloc, TvFeedState>(
      builder: (context, state) => FeedStateSwitcher(
        isLoading:
            state.status == TvFeedStatus.initial ||
            state.status == TvFeedStatus.loading,
        errorMessage: state.status == TvFeedStatus.error ? state.message : null,
        onRetry: () => context.read<TvFeedBloc>().add(const TvFeedRefreshed()),
        loadedBuilder: (context, topInset) =>
            _buildLoaded(context, state, topInset),
      ),
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    TvFeedState state,
    double topInset,
  ) {
    final rails = <Widget>[];
    void addRail(
      String title,
      List<PosterItem> items, {
      VoidCallback? onSeeAll,
    }) {
      if (items.isEmpty) return;
      rails
        ..add(const SizedBox(height: 24))
        ..add(
          FadeSlideIn(
            index: rails.length ~/ 2,
            child: DetailPosterRail(
              title: title,
              items: items,
              onTap: (item) => _open(context, item),
              onSeeAll: onSeeAll,
            ),
          ),
        );
    }

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

    final hasHero = state.trending.isNotEmpty;
    return RefreshIndicator(
      edgeOffset: topInset,
      onRefresh: () async =>
          context.read<TvFeedBloc>().add(const TvFeedRefreshed()),
      child: ListView(
        // With a hero, it extends up under the app bar itself; without one,
        // the rails start below the bar.
        padding: EdgeInsets.only(
          top: hasHero ? 0 : topInset,
          bottom: 24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          if (hasHero)
            FeaturedCarousel(
              items: state.trending.take(6).toList(),
              onTap: (item) => _openFeatured(context, item),
              heroTag: _heroTag,
              topInset: topInset,
            ),
          ...rails,
        ],
      ),
    );
  }
}
