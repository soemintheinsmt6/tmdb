import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/responsive/app_breakpoints.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/features/favourites/presentation/widgets/favourite_toggle_button.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_event.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_state.dart';
import 'package:tmdb/features/movies/presentation/widgets/movie_detail_cards.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';

class MovieDetailTabletLayout extends StatefulWidget {
  const MovieDetailTabletLayout({super.key, this.fallbackTitle});

  final String? fallbackTitle;

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor:
            _isScrolled ? colors.background : Colors.transparent,
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
              if (state is MovieDetailLoaded) {
                return FavouriteToggleButton(
                  movie: state.detail.toMovie(),
                  color: foreground,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<MovieDetailBloc, MovieDetailState>(
        builder: (context, state) {
          if (state is MovieDetailLoading || state is MovieDetailInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MovieDetailError) {
            return AppErrorView(
              message: state.message,
              onRetry: () {
                final bloc = context.read<MovieDetailBloc>();
                final id = (bloc.state is MovieDetailLoaded)
                    ? (bloc.state as MovieDetailLoaded).detail.id
                    : null;
                if (id != null) bloc.add(MovieDetailFetched(id));
              },
            );
          }
          if (state is MovieDetailLoaded) {
            final detail = state.detail;
            return ListView(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              children: [
                DetailHeader(detail: detail),
                Padding(
                  padding: EdgeInsets.fromLTRB(padding, 0, padding, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -64),
                        child: DetailSummary(detail: detail),
                      ),
                      DetailOverview(overview: detail.overview),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                DetailCastList(cast: detail.cast, horizontalPadding: padding),
                const SizedBox(height: 16),
                DetailRecommendations(
                  movies: detail.recommendations,
                  horizontalPadding: padding,
                ),
                const SizedBox(height: 32),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
