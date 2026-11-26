import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/home/presentation/bloc/home_bloc.dart';
import 'package:tmdb/features/home/presentation/bloc/home_event.dart';
import 'package:tmdb/features/home/presentation/bloc/home_state.dart';
import 'package:tmdb/features/home/presentation/screens/trending_screen.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_category_screen.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_detail/movie_detail_screen.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/features/tv/presentation/screens/tv_category_screen.dart';
import 'package:tmdb/features/tv/presentation/screens/tv_detail/tv_detail_screen.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';
import 'package:tmdb/shared/widgets/common/fade_slide_in.dart';
import 'package:tmdb/shared/widgets/detail/detail_cards.dart';
import 'package:tmdb/shared/widgets/feed/featured_carousel.dart';
import 'package:tmdb/shared/widgets/feed/feed_state_switcher.dart';

/// The editorial home body: a hero over a vertical stack of horizontal rails.
/// Mixed movie + TV items route to the right detail screen by runtime type.
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  /// How many trending titles the hero carousel shows.
  static const int _heroCount = 6;

  void _open(BuildContext context, PosterItem item) {
    final Widget screen = item is TvShow
        ? TvDetailScreen(tvShowId: item.id, title: item.title)
        : MovieDetailScreen(movieId: item.id, title: item.title);
    unawaited(pushView(context, screen));
  }

  /// Route-unique hero tag for a featured slide, prefixed so the home and
  /// series carousels never collide while both are alive in the IndexedStack.
  Object _heroTag(PosterItem item) => item is TvShow
      ? 'home-featured-tv-${item.id}'
      : 'home-featured-movie-${item.id}';

  /// Opens a featured (carousel) item with a shared backdrop hero transition.
  /// Seeds [backdropPath] so the detail header shows the same image instantly
  /// during the flight.
  void _openFeatured(BuildContext context, PosterItem item) {
    final Widget screen;
    if (item is TvShow) {
      screen = TvDetailScreen(
        tvShowId: item.id,
        title: item.title,
        heroTag: _heroTag(item),
        backdropPath: item.backdropPath,
      );
    } else if (item is Movie) {
      screen = MovieDetailScreen(
        movieId: item.id,
        title: item.title,
        heroTag: _heroTag(item),
        backdropPath: item.backdropPath,
      );
    } else {
      screen = MovieDetailScreen(movieId: item.id, title: item.title);
    }
    unawaited(pushView(context, screen));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) => FeedStateSwitcher(
        isLoading:
            state.status == HomeStatus.initial ||
            state.status == HomeStatus.loading,
        errorMessage: state.status == HomeStatus.error ? state.message : null,
        onRetry: () => context.read<HomeBloc>().add(const HomeRefreshed()),
        loadedBuilder: (context, topInset) =>
            _buildLoaded(context, state, topInset),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, HomeState state, double topInset) {
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

    // For You sits between the trending hero and the Trending rail so the two
    // don't read as a repeat (when it's empty, Trending follows the hero).
    addRail('For You', state.forYou);
    // The hero already shows the top titles; the rail picks up after them.
    addRail(
      'Trending',
      state.trending.skip(_heroCount).toList(),
      onSeeAll: () => unawaited(pushView(context, const TrendingScreen())),
    );
    addRail(
      'Now Playing',
      state.nowPlaying,
      onSeeAll: () =>
          _seeAllMovie(context, MovieCategory.nowPlaying, 'Now Playing'),
    );
    addRail(
      'Top Rated',
      state.topRated,
      onSeeAll: () =>
          _seeAllMovie(context, MovieCategory.topRated, 'Top Rated'),
    );
    addRail(
      'Upcoming',
      state.upcoming,
      onSeeAll: () => _seeAllMovie(context, MovieCategory.upcoming, 'Upcoming'),
    );
    addRail(
      'Popular Series',
      state.popularSeries,
      onSeeAll: () => _seeAllTv(context, TvCategory.popular, 'Popular Series'),
    );

    final hasHero = state.trending.isNotEmpty;
    return RefreshIndicator(
      edgeOffset: topInset,
      onRefresh: () async =>
          context.read<HomeBloc>().add(const HomeRefreshed()),
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
              items: state.trending.take(_heroCount).toList(),
              onTap: (item) => _openFeatured(context, item),
              heroTag: _heroTag,
              topInset: topInset,
            ),
          ...rails,
        ],
      ),
    );
  }

  void _seeAllMovie(
    BuildContext context,
    MovieCategory category,
    String title,
  ) {
    unawaited(
      pushView(context, MovieCategoryScreen(category: category, title: title)),
    );
  }

  void _seeAllTv(BuildContext context, TvCategory category, String title) {
    unawaited(
      pushView(context, TvCategoryScreen(category: category, title: title)),
    );
  }
}
