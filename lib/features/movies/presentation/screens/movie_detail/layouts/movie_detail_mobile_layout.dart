import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:tmdb/shared/domain/video.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';
import 'package:tmdb/shared/widgets/detail_cards.dart';
import 'package:tmdb/shared/widgets/trailer_player.dart';

class MovieDetailMobileLayout extends StatefulWidget {
  const MovieDetailMobileLayout({
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
  State<MovieDetailMobileLayout> createState() =>
      _MovieDetailMobileLayoutState();
}

class _MovieDetailMobileLayoutState extends State<MovieDetailMobileLayout> {
  final _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _suppressHero = false;

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
    final scrolled = _scrollController.offset > 120;
    if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
  }

  void _onPopInvoked(bool didPop, Object? result) {
    if (didPop || widget.heroTag == null) return;
    setState(() => _suppressHero = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = _isScrolled ? colors.textPrimary : Colors.white;
    final heroTag = _suppressHero ? null : widget.heroTag;
    return PopScope(
      canPop: widget.heroTag == null,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
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
                  ],
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<MovieDetailBloc, MovieDetailState>(
          builder: (context, state) {
            final loaded = state is MovieDetailLoaded ? state.detail : null;
            final backdropPath =
                loaded?.backdropPath ?? widget.seedBackdropPath;
            return ListView(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              children: [
                DetailHeader(backdropPath: backdropPath, heroTag: heroTag),
                if (loaded != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -40),
                          child: MovieDetailSummary(detail: loaded),
                        ),
                        DetailOverview(overview: loaded.overview),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  DetailVideoRail(
                    videos: loaded.videos.youTubeVideos,
                    onTap: (video) => playTrailer(context, video),
                  ),
                  const SizedBox(height: 24),
                  DetailImageGallery(images: loaded.images),
                  const SizedBox(height: 24),
                  DetailCastList(
                    cast: loaded.cast,
                    onTap: (member) => pushView(
                      context,
                      PersonDetailScreen(
                        personId: member.id,
                        name: member.name,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  MovieRecommendations(movies: loaded.recommendations),
                  const SizedBox(height: 24),
                  DetailReviewsSection(reviews: loaded.reviews),
                  const SizedBox(height: 24),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
