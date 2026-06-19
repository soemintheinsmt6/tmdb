import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/responsive/app_breakpoints.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/favourites/domain/entities/favourite_item.dart';
import 'package:tmdb/features/favourites/presentation/widgets/favourite_toggle_button.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_event.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_state.dart';
import 'package:tmdb/features/movies/presentation/widgets/movie_detail_cards.dart';
import 'package:tmdb/features/people/presentation/screens/person_detail/person_detail_screen.dart';
import 'package:tmdb/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:tmdb/features/watchlist/presentation/widgets/watchlist_toggle_button.dart';
import 'package:tmdb/shared/domain/shareable_media.dart';
import 'package:tmdb/shared/domain/video.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';
import 'package:tmdb/shared/widgets/detail_cards.dart';
import 'package:tmdb/shared/widgets/detail_skeleton.dart';
import 'package:tmdb/shared/widgets/share_button.dart';
import 'package:tmdb/shared/widgets/trailer_player.dart';
import 'package:tmdb/shared/widgets/watch_providers_section.dart';

class MovieDetailTabletLayout extends StatefulWidget {
  const MovieDetailTabletLayout({
    super.key,
    required this.movieId,
    this.fallbackTitle,
    this.seedBackdropPath,
    this.heroTag,
  });

  final int movieId;
  final String? fallbackTitle;
  final String? seedBackdropPath;
  final Object? heroTag;

  @override
  State<MovieDetailTabletLayout> createState() =>
      _MovieDetailTabletLayoutState();
}

class _MovieDetailTabletLayoutState extends State<MovieDetailTabletLayout> {
  final _scrollController = ScrollController();
  bool _isScrolled = false;

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
    final scrolled = _scrollController.offset > 160;
    if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
  }

  @override
  Widget build(BuildContext context) {
    final padding = context.horizontalPadding;
    final colors = context.colors;
    final foreground = _isScrolled ? colors.textPrimary : Colors.white;
    final heroTag = widget.heroTag;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _isScrolled ? colors.background : Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        iconTheme: IconThemeData(color: foreground),
        titleTextStyle: TextStyle(
          color: foreground,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        title: Text(_isScrolled ? (widget.fallbackTitle ?? '') : ''),
        actions: [
          BlocBuilder<MovieDetailBloc, MovieDetailState>(
            builder: (context, state) {
              if (state is! MovieDetailLoaded) return const SizedBox.shrink();
              final movie = state.detail.toMovie();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FavouriteToggleButton(
                    item: FavouriteItem.fromMovie(movie),
                    color: foreground,
                  ),
                  WatchlistToggleButton(
                    item: WatchlistItem.fromMovie(movie),
                    color: foreground,
                  ),
                  ShareButton(
                    media: ShareableMedia(
                      mediaType: MediaType.movie,
                      id: movie.id,
                      title: movie.title,
                      year: movie.releaseYear,
                      backdropUrl: movie.backdropUrl(),
                    ),
                    color: foreground,
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<MovieDetailBloc, MovieDetailState>(
        builder: (context, state) {
          final loaded = state is MovieDetailLoaded ? state.detail : null;
          final backdropPath = loaded?.backdropPath ?? widget.seedBackdropPath;
          // During loading we only have a real header when a backdrop or hero
          // was seeded from the previous screen; otherwise the skeleton draws
          // its own shimmer backdrop instead of a flat, inert block.
          final showHeader =
              loaded != null ||
              state is MovieDetailError ||
              (backdropPath != null && backdropPath.isNotEmpty) ||
              heroTag != null;
          return ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            children: [
              if (showHeader)
                DetailHeader(backdropPath: backdropPath, heroTag: heroTag),
              if (loaded != null) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(padding, 0, padding, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -64),
                        child: MovieDetailSummary(detail: loaded),
                      ),
                      DetailOverview(overview: loaded.overview),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                DetailVideoRail(
                  videos: loaded.videos.youTubeVideos,
                  horizontalPadding: padding,
                  onTap: (video) => playTrailer(context, video),
                ),
                const SizedBox(height: 32),
                DetailImageGallery(
                  images: loaded.images,
                  horizontalPadding: padding,
                ),
                const SizedBox(height: 32),
                DetailCastList(
                  cast: loaded.cast,
                  horizontalPadding: padding,
                  onTap: (member) => pushView(
                    context,
                    PersonDetailScreen(personId: member.id, name: member.name),
                  ),
                ),
                if (loaded.watchProviders?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 32),
                  WatchProvidersSection(
                    providers: loaded.watchProviders,
                    horizontalPadding: padding,
                  ),
                ],
                const SizedBox(height: 32),
                MovieRecommendations(
                  movies: loaded.recommendations,
                  horizontalPadding: padding,
                ),
                const SizedBox(height: 32),
                DetailReviewsSection(
                  reviews: loaded.reviews,
                  horizontalPadding: padding,
                ),
                const SizedBox(height: 32),
              ] else if (state is MovieDetailError) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: AppErrorView(
                    message: state.message,
                    onRetry: () => context.read<MovieDetailBloc>().add(
                      MovieDetailFetched(widget.movieId),
                    ),
                  ),
                ),
              ] else
                DetailSkeleton(
                  horizontalPadding: padding,
                  includeBackdrop: !showHeader,
                ),
            ],
          );
        },
      ),
    );
  }
}
