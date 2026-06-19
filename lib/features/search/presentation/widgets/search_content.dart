import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_detail/movie_detail_screen.dart';
import 'package:tmdb/features/people/presentation/screens/person_detail/person_detail_screen.dart';
import 'package:tmdb/features/search/domain/entities/search_filter.dart';
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
  Timer? _debounce;
  SearchFilter _filter = SearchFilter.all;

  /// Drives the results list. We prefer the route's [PrimaryScrollController]
  /// so an iOS status-bar tap — which [Scaffold] dispatches to that exact
  /// controller — scrolls the list to the top. [_ownedController] is a
  /// fallback used only when no primary is available (e.g. widget tests pumped
  /// without a route); we never dispose a controller we don't own.
  ScrollController? _scrollController;
  ScrollController? _ownedController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller =
        PrimaryScrollController.maybeOf(context) ??
        (_ownedController ??= ScrollController());
    if (identical(controller, _scrollController)) return;
    _scrollController?.removeListener(_onScroll);
    _scrollController = controller..addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _scrollController?.removeListener(_onScroll);
    _ownedController?.dispose();
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

  void _onFilterChanged(SearchFilter filter) {
    if (filter == _filter) return;
    setState(() => _filter = filter);
    context.read<SearchBloc>().add(SearchFilterChanged(filter));
  }

  void _onScroll() {
    final controller = _scrollController;
    if (controller == null || !controller.hasClients) return;
    final position = controller.position;
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
            autofocus: true,
            hint: 'Search movies, TV shows & people…',
            onChanged: _onSearchChanged,
            onClear: () {
              _debounce?.cancel();
              context.read<SearchBloc>().add(const SearchCleared());
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: _SearchFilterBar(
            selected: _filter,
            onChanged: _onFilterChanged,
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

/// Segmented media-type filter (All / Movies / TV / People) shown under the
/// search field. Mirrors the Discover toggle's cyan-selected styling.
class _SearchFilterBar extends StatelessWidget {
  const _SearchFilterBar({required this.selected, required this.onChanged});

  final SearchFilter selected;
  final ValueChanged<SearchFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<SearchFilter>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colors.textSecondary,
          selectedBackgroundColor: AppColors.cyan,
          selectedForegroundColor: isDark ? AppColors.navy : AppColors.white,
          side: BorderSide(color: colors.border),
          textStyle: AppTypography.smallText.copyWith(
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        segments: [
          for (final filter in SearchFilter.values)
            ButtonSegment(value: filter, label: Text(filter.label)),
        ],
        selected: {selected},
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );
  }
}
