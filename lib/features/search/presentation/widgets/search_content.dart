import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_detail/movie_detail_screen.dart';
import 'package:tmdb/features/people/presentation/screens/person_detail/person_detail_screen.dart';
import 'package:tmdb/features/search/domain/entities/search_result.dart';
import 'package:tmdb/features/search/presentation/bloc/search_bloc/search_bloc.dart';
import 'package:tmdb/features/search/presentation/bloc/search_bloc/search_event.dart';
import 'package:tmdb/features/search/presentation/bloc/search_bloc/search_state.dart';
import 'package:tmdb/features/search/presentation/widgets/search_result_tile.dart';
import 'package:tmdb/features/search/presentation/widgets/search_results_skeleton.dart';
import 'package:tmdb/features/tv/presentation/screens/tv_detail/tv_detail_screen.dart';
import 'package:tmdb/shared/widgets/app_empty_view.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';
import 'package:tmdb/shared/widgets/app_search_field.dart';

/// The body of the search screen. Handles query debouncing, infinite scroll,
/// and routing each mixed result to its matching detail screen.
class SearchContent extends StatefulWidget {
  const SearchContent({super.key});

  @override
  State<SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<SearchContent> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      context.read<SearchBloc>().add(const SearchCleared());
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<SearchBloc>().add(SearchQueryChanged(value));
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 320) return;

    final state = context.read<SearchBloc>().state;
    if (state is SearchLoaded && state.hasMore && !state.isLoadingMore) {
      context.read<SearchBloc>().add(const SearchLoadMore());
    }
  }

  void _openResult(SearchResult result) {
    final Widget screen = switch (result.mediaType) {
      SearchMediaType.movie => MovieDetailScreen(
        movieId: result.id,
        title: result.title,
      ),
      SearchMediaType.tv => TvDetailScreen(
        tvShowId: result.id,
        title: result.title,
      ),
      SearchMediaType.person => PersonDetailScreen(
        personId: result.id,
        name: result.title,
      ),
    };
    unawaited(pushView(context, screen));
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
            hint: 'Search movies, TV shows & people…',
            onChanged: _onSearchChanged,
            onClear: () {
              _debounce?.cancel();
              context.read<SearchBloc>().add(const SearchCleared());
            },
          ),
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchIdle) {
          return const AppEmptyView(
            icon: IconsaxPlusLinear.search_normal_1,
            message: 'Find movies, TV shows & people',
          );
        }
        if (state is SearchLoading) {
          return const SearchResultsSkeleton();
        }
        if (state is SearchError) {
          return AppErrorView(
            message: state.message,
            onRetry: () => context.read<SearchBloc>().add(
              SearchQueryChanged(_searchCtrl.text),
            ),
          );
        }
        if (state is SearchLoaded) {
          if (state.results.isEmpty) {
            return AppEmptyView(message: 'No results for "${state.query}"');
          }
          final hasFooter = state.isLoadingMore;
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.results.length + (hasFooter ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.results.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                );
              }
              final result = state.results[index];
              return SearchResultTile(
                result: result,
                onTap: () => _openResult(result),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
