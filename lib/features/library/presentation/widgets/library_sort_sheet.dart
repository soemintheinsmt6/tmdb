import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/shared/domain/library/library_sort.dart';

/// Shows the library sort sheet and resolves to the chosen [LibrarySort], or
/// `null` if dismissed without a selection.
Future<LibrarySort?> showLibrarySortSheet(
  BuildContext context, {
  required LibrarySort selected,
}) {
  return showModalBottomSheet<LibrarySort>(
    context: context,
    backgroundColor: context.colors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _LibrarySortSheet(selected: selected),
  );
}

class _LibrarySortSheet extends StatelessWidget {
  const _LibrarySortSheet({required this.selected});

  final LibrarySort selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
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
            const Text('Sort by', style: AppTypography.subTitle),
            const SizedBox(height: 4),
            for (final option in LibrarySort.values)
              _SortOptionTile(
                option: option,
                selected: option == selected,
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  const _SortOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final LibrarySort option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        option.label,
        style: AppTypography.bodyText.copyWith(
          color: selected ? AppColors.cyan : colors.textPrimary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: selected
          ? const Icon(IconsaxPlusBold.tick_circle, color: AppColors.cyan)
          : null,
    );
  }
}
