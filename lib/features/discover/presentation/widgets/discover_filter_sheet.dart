import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/features/discover/domain/entities/discover_filter.dart';
import 'package:tmdb/shared/domain/genre.dart';

/// Shows the discover filter sheet and resolves to the edited [DiscoverFilter],
/// or `null` if the user dismisses it without applying.
Future<DiscoverFilter?> showDiscoverFilterSheet(
  BuildContext context, {
  required DiscoverFilter filter,
  required List<Genre> genres,
}) {
  return showModalBottomSheet<DiscoverFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _DiscoverFilterSheet(filter: filter, genres: genres),
  );
}

class _DiscoverFilterSheet extends StatefulWidget {
  const _DiscoverFilterSheet({required this.filter, required this.genres});

  final DiscoverFilter filter;
  final List<Genre> genres;

  @override
  State<_DiscoverFilterSheet> createState() => _DiscoverFilterSheetState();
}

class _DiscoverFilterSheetState extends State<_DiscoverFilterSheet> {
  late DiscoverSort _sort;
  late Set<int> _genreIds;
  late double _minRating;
  int? _year;

  // Year options: a sensible recent range. The newest year is the maximum
  // release year we expect data for; kept static to avoid a Date dependency.
  static const int _maxYear = 2026;
  static const int _minYear = 1950;

  @override
  void initState() {
    super.initState();
    _sort = widget.filter.sort;
    _genreIds = {...widget.filter.genreIds};
    _minRating = widget.filter.minRating;
    _year = widget.filter.year;
  }

  void _reset() {
    setState(() {
      _sort = DiscoverSort.popularityDesc;
      _genreIds = {};
      _minRating = 0;
      _year = null;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      DiscoverFilter(
        genreIds: _genreIds,
        sort: _sort,
        minRating: _minRating,
        year: _year,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Filters', style: AppTypography.subTitle),
                const Spacer(),
                TextButton(onPressed: _reset, child: const Text('Reset')),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Sort by'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final sort in DiscoverSort.values) _sortChip(sort),
                      ],
                    ),
                    if (widget.genres.isNotEmpty) ...[
                      _label('Genres'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final genre in widget.genres) _genreChip(genre),
                        ],
                      ),
                    ],
                    _label('Minimum rating: ${_minRating.toStringAsFixed(0)}+'),
                    Slider(
                      value: _minRating,
                      max: 9,
                      activeColor: AppColors.cyan,
                      // No divisions → continuous, smooth drag; the header above
                      // reflects the value live as it changes.
                      onChanged: (v) => setState(() => _minRating = v),
                    ),
                    _label('Release year'),
                    _YearDropdown(
                      year: _year,
                      minYear: _minYear,
                      maxYear: _maxYear,
                      onChanged: (y) => setState(() => _year = y),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  // White label on the cyan button in light mode; theme default
                  // (navy) in dark.
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? null
                      : AppColors.white,
                ),
                onPressed: _apply,
                child: const Text('Show results'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        text,
        style: AppTypography.bodyText.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  /// Single-select sort chip.
  Widget _sortChip(DiscoverSort sort) {
    return _Chip(
      label: sort.label,
      selected: _sort == sort,
      onTap: () => setState(() => _sort = sort),
    );
  }

  /// Multi-select genre chip.
  Widget _genreChip(Genre genre) {
    final selected = _genreIds.contains(genre.id);
    return _Chip(
      label: genre.name,
      selected: selected,
      onTap: () => setState(() {
        if (selected) {
          _genreIds.remove(genre.id);
        } else {
          _genreIds.add(genre.id);
        }
      }),
    );
  }
}

/// A custom pill chip with fully-controlled colours (Material's [FilterChip]
/// overrides the selected label colour inconsistently across light/dark): a
/// cyan fill with navy bold label when selected; an outlined "ghost" pill
/// (transparent fill, thin border, secondary label) when not.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // White label on the cyan fill in light mode; navy in dark mode.
    final selectedLabelColor = isDark ? AppColors.navy : AppColors.white;
    return Material(
      color: Colors.transparent,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.cyan : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.cyan : colors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.smallText.copyWith(
              color: selected ? selectedLabelColor : colors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _YearDropdown extends StatelessWidget {
  const _YearDropdown({
    required this.year,
    required this.minYear,
    required this.maxYear,
    required this.onChanged,
  });

  final int? year;
  final int minYear;
  final int maxYear;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButton<int?>(
        value: year,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        hint: const Text('Any year', style: AppTypography.bodyText),
        style: AppTypography.bodyText.copyWith(color: colors.textPrimary),
        dropdownColor: colors.surface,
        icon: Icon(
          IconsaxPlusLinear.arrow_down,
          size: 18,
          color: colors.textMuted,
        ),
        items: [
          const DropdownMenuItem<int?>(child: Text('Any year')),
          for (int y = maxYear; y >= minYear; y--)
            DropdownMenuItem<int?>(value: y, child: Text('$y')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
