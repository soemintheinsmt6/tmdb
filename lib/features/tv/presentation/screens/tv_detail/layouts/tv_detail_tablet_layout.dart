import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/responsive/app_breakpoints.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/people/presentation/screens/person_detail/person_detail_screen.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_detail_bloc/tv_detail_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_detail_bloc/tv_detail_event.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_detail_bloc/tv_detail_state.dart';
import 'package:tmdb/features/tv/presentation/widgets/tv_detail_cards.dart';
import 'package:tmdb/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:tmdb/features/watchlist/presentation/widgets/watchlist_toggle_button.dart';
import 'package:tmdb/shared/domain/video.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';
import 'package:tmdb/shared/widgets/detail_cards.dart';
import 'package:tmdb/shared/widgets/trailer_player.dart';

class TvDetailTabletLayout extends StatefulWidget {
  const TvDetailTabletLayout({
    super.key,
    required this.tvShowId,
    this.fallbackTitle,
    this.seedBackdropPath,
    this.heroTag,
  });

  final int tvShowId;
  final String? fallbackTitle;
  final String? seedBackdropPath;
  final Object? heroTag;

  @override
  State<TvDetailTabletLayout> createState() => _TvDetailTabletLayoutState();
}

class _TvDetailTabletLayoutState extends State<TvDetailTabletLayout> {
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
    final scrolled = _scrollController.offset > 160;
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
    final padding = context.horizontalPadding;
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
            BlocBuilder<TvDetailBloc, TvDetailState>(
              builder: (context, state) {
                if (state is! TvDetailLoaded) return const SizedBox.shrink();
                return WatchlistToggleButton(
                  item: WatchlistItem.fromTvShow(state.detail.toTvShow()),
                  color: foreground,
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<TvDetailBloc, TvDetailState>(
          builder: (context, state) {
            final loaded = state is TvDetailLoaded ? state.detail : null;
            final backdropPath =
                loaded?.backdropPath ?? widget.seedBackdropPath;
            return ListView(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              children: [
                DetailHeader(backdropPath: backdropPath, heroTag: heroTag),
                if (loaded != null) ...[
                  Padding(
                    padding: EdgeInsets.fromLTRB(padding, 0, padding, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -64),
                          child: TvDetailSummary(detail: loaded),
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
                      PersonDetailScreen(
                        personId: member.id,
                        name: member.name,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TvRecommendations(
                    shows: loaded.recommendations,
                    horizontalPadding: padding,
                  ),
                  const SizedBox(height: 32),
                  DetailReviewsSection(
                    reviews: loaded.reviews,
                    horizontalPadding: padding,
                  ),
                  const SizedBox(height: 32),
                ] else if (state is TvDetailError) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: AppErrorView(
                      message: state.message,
                      onRetry: () => context.read<TvDetailBloc>().add(
                        TvDetailFetched(widget.tvShowId),
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
