import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/discover/domain/entities/discover_filter.dart';
import 'package:tmdb/features/discover/presentation/bloc/discover_bloc.dart';
import 'package:tmdb/features/discover/presentation/bloc/discover_event.dart';
import 'package:tmdb/features/discover/presentation/bloc/discover_state.dart';
import 'package:tmdb/features/discover/presentation/widgets/discover_content.dart';
import 'package:tmdb/features/discover/presentation/widgets/discover_filter_sheet.dart';
import 'package:tmdb/features/search/presentation/screens/search_screen.dart';
import 'package:tmdb/injection_container.dart';

/// Browse movies or TV shows by genre, rating, year, and sort order via
/// `/discover/{movie,tv}`. A media-type toggle switches verticals; active
/// filters surface as removable chips below it.
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
        titleSpacing: NavigationToolbar.kMiddleSpacing,
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
      body: const SafeArea(
        child: Column(
          children: [
            _MediaToggle(),
            _ActiveFilters(),
            Expanded(child: DiscoverContent()),
          ],
        ),
      ),
    );
  }
}

/// Movies / TV segmented toggle. Switching reloads the grid and genre list.
class _MediaToggle extends StatelessWidget {
  const _MediaToggle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: BlocBuilder<DiscoverBloc, DiscoverState>(
        buildWhen: (a, b) => a.filter.mediaType != b.filter.mediaType,
        builder: (context, state) {
          final colors = context.colors;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return SegmentedButton<MediaType>(
            showSelectedIcon: false,
            // The Material default selected tone (secondaryContainer) is nearly
            // indistinguishable from the surface in this app's dark scheme, so
            // give the selected segment an explicit cyan fill (matching the
            // filter chips) for a clear active state in both themes.
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: colors.textSecondary,
              selectedBackgroundColor: AppColors.cyan,
              selectedForegroundColor: isDark
                  ? AppColors.navy
                  : AppColors.white,
              side: BorderSide(color: colors.border),
            ),
            segments: const [
              ButtonSegment(value: MediaType.movie, label: Text('Movies')),
              ButtonSegment(value: MediaType.tv, label: Text('TV Shows')),
            ],
            selected: {state.filter.mediaType},
            onSelectionChanged: (selection) => context
                .read<DiscoverBloc>()
                .add(DiscoverMediaTypeChanged(selection.first)),
          );
        },
      ),
    );
  }
}

/// Horizontal row of removable chips for each active filter facet. Hidden when
/// no facet is active.
class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverBloc, DiscoverState>(
      buildWhen: (a, b) => a.filter != b.filter || a.genres != b.genres,
      builder: (context, state) {
        final filter = state.filter;
        if (!filter.isActive) return const SizedBox.shrink();

        void apply(DiscoverFilter next) =>
            context.read<DiscoverBloc>().add(DiscoverFilterApplied(next));

        final chips = <Widget>[];

        if (filter.sort != DiscoverSort.popularityDesc) {
          chips.add(
            _RemovableChip(
              label: filter.sort.label,
              onRemove: () =>
                  apply(filter.copyWith(sort: DiscoverSort.popularityDesc)),
            ),
          );
        }
        for (final id in filter.genreIds) {
          final matches = state.genres.where((g) => g.id == id);
          if (matches.isEmpty) continue;
          chips.add(
            _RemovableChip(
              label: matches.first.name,
              onRemove: () => apply(
                filter.copyWith(
                  genreIds: Set<int>.from(filter.genreIds)..remove(id),
                ),
              ),
            ),
          );
        }
        if (filter.minRating > 0) {
          chips.add(
            _RemovableChip(
              label: '★ ${filter.minRating.toStringAsFixed(0)}+',
              onRemove: () => apply(filter.copyWith(minRating: 0)),
            ),
          );
        }
        if (filter.year != null) {
          chips.add(
            _RemovableChip(
              label: '${filter.year}',
              onRemove: () => apply(filter.copyWith(clearYear: true)),
            ),
          );
        }

        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            itemCount: chips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) => chips[index],
          ),
        );
      },
    );
  }
}

/// A pill chip with a trailing close affordance, styled to match the app.
class _RemovableChip extends StatelessWidget {
  const _RemovableChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surfaceMuted,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onRemove,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(IconsaxPlusLinear.close_circle, size: 16, color: colors.textMuted),
            ],
          ),
        ),
      ),
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
