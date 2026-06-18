import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_event.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_state.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_detail/movie_detail_screen.dart';
import 'package:tmdb/injection_container.dart';
import 'package:tmdb/shared/domain/poster_item.dart';
import 'package:tmdb/shared/widgets/app_empty_view.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';
import 'package:tmdb/shared/widgets/poster_grid.dart';
import 'package:tmdb/shared/widgets/poster_grid_skeleton.dart';

/// Full, paginated grid for a single movie category — reached from a home rail's
/// "See all". Reuses [MovieListBloc]'s infinite-scroll loading.
class MovieCategoryScreen extends StatelessWidget {
  const MovieCategoryScreen({
    super.key,
    required this.category,
    required this.title,
  });

  final MovieCategory category;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MovieListBloc(
        repository: sl<MovieRepository>(),
        initialCategory: category,
      ),
      child: Scaffold(
        appBar: AppBar(titleSpacing: 0, title: Text(title)),
        body: SafeArea(child: _MovieCategoryGrid(category: category)),
      ),
    );
  }
}

class _MovieCategoryGrid extends StatefulWidget {
  const _MovieCategoryGrid({required this.category});

  final MovieCategory category;

  @override
  State<_MovieCategoryGrid> createState() => _MovieCategoryGridState();
}

class _MovieCategoryGridState extends State<_MovieCategoryGrid> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (position.pixels < position.maxScrollExtent - 320) return;
    final state = context.read<MovieListBloc>().state;
    if (state is MovieListLoaded && state.hasMore && !state.isLoadingMore) {
      context.read<MovieListBloc>().add(const MovieListLoadMore());
    }
  }

  void _open(PosterItem item) => unawaited(
    pushView(context, MovieDetailScreen(movieId: item.id, title: item.title)),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieListBloc, MovieListState>(
      builder: (context, state) {
        if (state is MovieListInitial || state is MovieListLoading) {
          return const PosterGridSkeleton();
        }
        if (state is MovieListError) {
          return AppErrorView(
            message: state.message,
            onRetry: () => context.read<MovieListBloc>().add(
              MovieListCategoryChanged(widget.category),
            ),
          );
        }
        if (state is MovieListLoaded) {
          if (state.movies.isEmpty) {
            return const AppEmptyView(message: 'Nothing to show');
          }
          return PosterGrid(
            scrollController: _controller,
            items: state.movies,
            onTap: _open,
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
        return const SizedBox.shrink();
      },
    );
  }
}
