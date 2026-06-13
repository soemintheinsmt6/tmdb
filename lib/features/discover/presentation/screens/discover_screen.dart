import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/discover/presentation/bloc/discover_bloc.dart';
import 'package:tmdb/features/discover/presentation/bloc/discover_event.dart';
import 'package:tmdb/features/discover/presentation/bloc/discover_state.dart';
import 'package:tmdb/features/discover/presentation/widgets/discover_content.dart';
import 'package:tmdb/features/discover/presentation/widgets/discover_filter_sheet.dart';
import 'package:tmdb/features/search/presentation/screens/search_screen.dart';
import 'package:tmdb/injection_container.dart';

/// Browse movies by genre, rating, year, and sort order via `/discover/movie`.
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DiscoverBloc>()..add(const DiscoverStarted()),
      child: const _DiscoverView(),
    );
  }
}

class _DiscoverView extends StatelessWidget {
  const _DiscoverView();

  Future<void> _openFilters(BuildContext context) async {
    final bloc = context.read<DiscoverBloc>();
    final result = await showDiscoverFilterSheet(
      context,
      filter: bloc.state.filter,
      genres: bloc.state.genres,
    );
    if (result != null) bloc.add(DiscoverFilterApplied(result));
  }

  Future<void> _openSearch(BuildContext context) {
    return pushView(context, const SearchScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(IconsaxPlusLinear.search_normal_1),
            onPressed: () => _openSearch(context),
          ),
          BlocBuilder<DiscoverBloc, DiscoverState>(
            buildWhen: (a, b) => a.filter != b.filter,
            builder: (context, state) {
              return _FilterButton(
                count: state.filter.activeCount,
                onPressed: () => _openFilters(context),
              );
            },
          ),
        ],
      ),
      body: const SafeArea(child: DiscoverContent()),
    );
  }
}

/// Filter icon with a small badge showing the number of active facets.
class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: 'Filters',
          icon: const Icon(IconsaxPlusLinear.setting_4),
          onPressed: onPressed,
        ),
        if (count > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: const BoxDecoration(
                color: AppColors.cyan,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
