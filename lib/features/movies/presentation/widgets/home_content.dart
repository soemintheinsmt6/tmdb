import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/movies/data/models/movie.dart';
import 'package:tmdb/features/movies/data/repositories/movie_repository.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_event.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_state.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_search_bloc/movie_search_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_search_bloc/movie_search_event.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_search_bloc/movie_search_state.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_detail/movie_detail_screen.dart';
import 'package:tmdb/features/movies/presentation/widgets/category_tab_bar.dart';
import 'package:tmdb/features/movies/presentation/widgets/movie_grid.dart';
import 'package:tmdb/features/movies/presentation/widgets/movie_list_skeleton.dart';
import 'package:tmdb/shared/widgets/app_empty_view.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';
import 'package:tmdb/shared/widgets/app_search_field.dart';

/// The body of the home screen, shared between mobile and tablet layouts.
/// Handles search debouncing, category tabs, infinite scroll, and routing
/// to the detail screen.
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: MovieCategory.values.length,
      vsync: this,
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onCategoryTap(MovieCategory category) {
    context.read<MovieListBloc>().add(MovieListCategoryChanged(category));
    _scrollController.jumpTo(0);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      context.read<MovieSearchBloc>().add(const MovieSearchCleared());
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<MovieSearchBloc>().add(MovieSearchQueryChanged(value));
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 320) return;

    final searchState = context.read<MovieSearchBloc>().state;
    if (searchState is MovieSearchLoaded) {
      if (searchState.hasMore && !searchState.isLoadingMore) {
        context.read<MovieSearchBloc>().add(const MovieSearchLoadMore());
      }
      return;
    }

    final listState = context.read<MovieListBloc>().state;
    if (listState is MovieListLoaded &&
        listState.hasMore &&
        !listState.isLoadingMore) {
      context.read<MovieListBloc>().add(const MovieListLoadMore());
    }
  }

  Future<void> _onRefresh() async {
    context.read<MovieListBloc>().add(const MovieListRefreshed());
  }

  void _openDetail(Movie movie) {
    pushView(context, MovieDetailScreen(movieId: movie.id, title: movie.title));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: AppSearchField(
            controller: _searchCtrl,
            focusNode: _searchFocus,
            hint: 'Search movies…',
            onChanged: _onSearchChanged,
            onClear: () {
              _debounce?.cancel();
              context.read<MovieSearchBloc>().add(const MovieSearchCleared());
            },
          ),
        ),
        BlocBuilder<MovieSearchBloc, MovieSearchState>(
          builder: (context, state) {
            final showCategories = state is MovieSearchIdle;
            return showCategories
                ? CategoryTabBar(
                    controller: _tabController,
                    onChanged: _onCategoryTap,
                  )
                : const SizedBox.shrink();
          },
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    return BlocBuilder<MovieSearchBloc, MovieSearchState>(
      builder: (context, searchState) {
        if (searchState is MovieSearchLoading) {
          return const MovieListSkeleton();
        }
        if (searchState is MovieSearchError) {
          return AppErrorView(message: searchState.message);
        }
        if (searchState is MovieSearchLoaded) {
          if (searchState.movies.isEmpty) {
            return AppEmptyView(
              message: 'No matches for "${searchState.query}"',
            );
          }
          return MovieGrid(
            scrollController: _scrollController,
            movies: searchState.movies,
            onTap: _openDetail,
            footer: searchState.isLoadingMore
                ? const Center(child: CircularProgressIndicator())
                : null,
          );
        }
        return _buildCategoryList();
      },
    );
  }

  Widget _buildCategoryList() {
    return BlocBuilder<MovieListBloc, MovieListState>(
      builder: (context, state) {
        if (state is MovieListInitial || state is MovieListLoading) {
          return const MovieListSkeleton();
        }
        if (state is MovieListError) {
          return AppErrorView(
            message: state.message,
            onRetry: () => context
                .read<MovieListBloc>()
                .add(MovieListCategoryChanged(state.category)),
          );
        }
        if (state is MovieListLoaded) {
          if (state.movies.isEmpty) {
            return const AppEmptyView(message: 'No movies to show');
          }
          return MovieGrid(
            scrollController: _scrollController,
            movies: state.movies,
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
        return const SizedBox.shrink();
      },
    );
  }
}
