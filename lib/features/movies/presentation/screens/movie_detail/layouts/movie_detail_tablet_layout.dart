import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/responsive/app_breakpoints.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_event.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_state.dart';
import 'package:tmdb/features/movies/presentation/widgets/movie_detail_cards.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';

class MovieDetailTabletLayout extends StatelessWidget {
  const MovieDetailTabletLayout({super.key, this.fallbackTitle});

  final String? fallbackTitle;

  @override
  Widget build(BuildContext context) {
    final padding = context.horizontalPadding;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(fallbackTitle ?? ''),
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
              padding: EdgeInsets.zero,
              children: [
                DetailHeader(detail: detail),
                Padding(
                  padding: EdgeInsets.fromLTRB(padding, 0, padding, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -64),
                        child: DetailSummary(detail: detail),
                      ),
                      DetailOverview(overview: detail.overview),
                      const SizedBox(height: 32),
                      DetailCastList(cast: detail.cast),
                      const SizedBox(height: 32),
                      DetailRecommendations(movies: detail.recommendations),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
