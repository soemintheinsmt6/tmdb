import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_list_bloc/tv_list_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_list_bloc/tv_list_event.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_list_bloc/tv_list_state.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_search_bloc/tv_search_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_search_bloc/tv_search_event.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_search_bloc/tv_search_state.dart';
import 'package:tmdb/features/tv/presentation/screens/tv_detail/tv_detail_screen.dart';
import 'package:tmdb/shared/domain/poster_item.dart';
import 'package:tmdb/shared/widgets/app_empty_view.dart';
import 'package:tmdb/shared/widgets/app_error_view.dart';
import 'package:tmdb/shared/widgets/app_search_field.dart';
import 'package:tmdb/shared/widgets/category_tab_bar.dart';
import 'package:tmdb/shared/widgets/poster_grid.dart';
import 'package:tmdb/shared/widgets/poster_grid_skeleton.dart';

/// Tab labels for each [TvCategory], in enum order.
const Map<TvCategory, String> kTvCategoryLabels = {
  TvCategory.popular: 'Popular',
  TvCategory.topRated: 'Top Rated',
  TvCategory.onTheAir: 'On The Air',
  TvCategory.airingToday: 'Airing Today',
};

/// The body of the TV screen, shared between mobile and tablet layouts.
/// Handles search debouncing, category tabs, infinite scroll, and routing to
/// the detail screen. Mirrors `HomeContent` for the TV vertical.
class TvContent extends StatefulWidget {
  const TvContent({super.key});

  @override
  State<TvContent> createState() => _TvContentState();
}

class _TvContentState extends State<TvContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  /// Drives the poster grids. We prefer the ambient [PrimaryScrollController]
  /// (the active tab's controller, supplied by `RootScreen`) so an iOS
  /// status-bar tap scrolls this list to the top. [_ownedController] is a
  /// fallback used only when no primary is available (e.g. widget tests pumped
  /// without a route); we never dispose a controller we don't own.
  ScrollController? _scrollController;
  ScrollController? _ownedController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: TvCategory.values.length,
      vsync: this,
    );
  }

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
    _tabController.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _scrollController?.removeListener(_onScroll);
    _ownedController?.dispose();
    super.dispose();
  }

  void _onCategoryTap(TvCategory category) {
    context.read<TvListBloc>().add(TvListCategoryChanged(category));
    final controller = _scrollController;
    if (controller != null && controller.hasClients) {
      controller.jumpTo(0);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      context.read<TvSearchBloc>().add(const TvSearchCleared());
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<TvSearchBloc>().add(TvSearchQueryChanged(value));
    });
  }

  void _onScroll() {
    final controller = _scrollController;
    if (controller == null || !controller.hasClients) return;
    final position = controller.position;
    if (position.pixels < position.maxScrollExtent - 320) return;

    final searchState = context.read<TvSearchBloc>().state;
    if (searchState is TvSearchLoaded) {
      if (searchState.hasMore && !searchState.isLoadingMore) {
        context.read<TvSearchBloc>().add(const TvSearchLoadMore());
      }
      return;
    }

    final listState = context.read<TvListBloc>().state;
    if (listState is TvListLoaded &&
        listState.hasMore &&
        !listState.isLoadingMore) {
      context.read<TvListBloc>().add(const TvListLoadMore());
    }
  }

  Future<void> _onRefresh() async {
    context.read<TvListBloc>().add(const TvListRefreshed());
  }

  void _openDetail(PosterItem item) {
    unawaited(
      pushView(context, TvDetailScreen(tvShowId: item.id, title: item.title)),
    );
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
            hint: 'Search TV shows…',
            onChanged: _onSearchChanged,
            onClear: () {
              _debounce?.cancel();
              context.read<TvSearchBloc>().add(const TvSearchCleared());
            },
          ),
        ),
        BlocBuilder<TvSearchBloc, TvSearchState>(
          builder: (context, state) {
            final showCategories = state is TvSearchIdle;
            return showCategories
                ? CategoryTabBar(
                    controller: _tabController,
                    labels: [
                      for (final c in TvCategory.values) kTvCategoryLabels[c]!,
                    ],
                    onIndexChanged: (i) => _onCategoryTap(TvCategory.values[i]),
                  )
                : const SizedBox.shrink();
          },
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    return BlocBuilder<TvSearchBloc, TvSearchState>(
      builder: (context, searchState) {
        if (searchState is TvSearchLoading) {
          return const PosterGridSkeleton();
        }
        if (searchState is TvSearchError) {
          return AppErrorView(message: searchState.message);
        }
        if (searchState is TvSearchLoaded) {
          if (searchState.shows.isEmpty) {
            return AppEmptyView(
              message: 'No matches for "${searchState.query}"',
            );
          }
          return PosterGrid(
            scrollController: _scrollController,
            items: searchState.shows,
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
    return BlocBuilder<TvListBloc, TvListState>(
      builder: (context, state) {
        if (state is TvListInitial || state is TvListLoading) {
          return const PosterGridSkeleton();
        }
        if (state is TvListError) {
          return AppErrorView(
            message: state.message,
            onRetry: () => context.read<TvListBloc>().add(
              TvListCategoryChanged(state.category),
            ),
          );
        }
        if (state is TvListLoaded) {
          if (state.shows.isEmpty) {
            return const AppEmptyView(message: 'No TV shows to show');
          }
          return PosterGrid(
            scrollController: _scrollController,
            items: state.shows,
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
