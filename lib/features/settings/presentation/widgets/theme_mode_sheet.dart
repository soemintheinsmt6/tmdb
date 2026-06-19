import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';

/// Display helpers for [ThemeMode] in the appearance picker.
extension ThemeModeDisplay on ThemeMode {
  String get label => switch (this) {
    ThemeMode.system => 'System default',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  IconData get icon => switch (this) {
    ThemeMode.system => IconsaxPlusLinear.mobile,
    ThemeMode.light => IconsaxPlusLinear.sun_1,
    ThemeMode.dark => IconsaxPlusLinear.moon,
  };
}

/// Shows the appearance picker and resolves to the chosen [ThemeMode], or
/// `null` if dismissed without a selection.
Future<ThemeMode?> showThemeModeSheet(
  BuildContext context, {
  required ThemeMode selected,
}) {
  return showModalBottomSheet<ThemeMode>(
    context: context,
    backgroundColor: context.colors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ThemeModeSheet(selected: selected),
  );
}

class _ThemeModeSheet extends StatelessWidget {
  const _ThemeModeSheet({required this.selected});

  final ThemeMode selected;

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
            const Text('Appearance', style: AppTypography.subTitle),
            const SizedBox(height: 4),
            for (final mode in ThemeMode.values)
              _ThemeModeTile(
                mode: mode,
                selected: mode == selected,
                onTap: () => Navigator.of(context).pop(mode),
              ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(
        mode.icon,
        size: 22,
        color: selected ? AppColors.cyan : colors.textSecondary,
      ),
      title: Text(
        mode.label,
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
