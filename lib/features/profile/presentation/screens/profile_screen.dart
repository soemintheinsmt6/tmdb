import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_state.dart';
import 'package:tmdb/features/profile/presentation/widgets/profile_header.dart';
import 'package:tmdb/features/profile/presentation/widgets/settings_tile.dart';
import 'package:tmdb/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:tmdb/features/settings/presentation/widgets/theme_mode_sheet.dart';
import 'package:tmdb/features/watchlist/presentation/cubit/watchlist_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          BlocSelector<FavouritesCubit, FavouritesState, int>(
            selector: (state) => state.items.length,
            builder: (context, count) {
              return ProfileHeader(
                name: 'Movie Fan',
                subtitle: count == 1 ? '1 favourite' : '$count favourites',
              );
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Settings',
              style: AppTypography.smallText.copyWith(
                color: context.colors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) => SettingsTile(
              icon: IconsaxPlusLinear.moon,
              title: 'Appearance',
              subtitle: mode.label,
              onTap: () => _pickTheme(context, mode),
            ),
          ),
          const SizedBox(height: 10),
          SettingsTile(
            icon: IconsaxPlusLinear.trash,
            title: 'Clear favourites',
            subtitle: 'Remove every saved title',
            iconColor: AppColors.error,
            onTap: () => _confirmClearFavourites(context),
          ),
          const SizedBox(height: 10),
          SettingsTile(
            icon: IconsaxPlusLinear.trash,
            title: 'Clear watchlist',
            subtitle: 'Remove every saved title',
            iconColor: AppColors.error,
            onTap: () => _confirmClearWatchlist(context),
          ),
          const SizedBox(height: 10),
          SettingsTile(
            icon: IconsaxPlusLinear.info_circle,
            title: 'About',
            onTap: () => _showAbout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTheme(BuildContext context, ThemeMode current) async {
    final cubit = context.read<ThemeCubit>();
    final selected = await showThemeModeSheet(context, selected: current);
    if (selected == null) return;
    await cubit.setThemeMode(selected);
  }

  Future<void> _confirmClearFavourites(BuildContext context) async {
    final cubit = context.read<FavouritesCubit>();
    if (cubit.state.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No favourites to clear')));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear favourites?'),
        content: const Text(
          'This will remove every title from your favourites. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await cubit.clear();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Favourites cleared')));
  }

  Future<void> _confirmClearWatchlist(BuildContext context) async {
    final cubit = context.read<WatchlistCubit>();
    if (cubit.state.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No watchlist to clear')));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear watchlist?'),
        content: const Text(
          'This will remove every title from your watchlist. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await cubit.clear();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Watchlist cleared')));
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'TMDB',
      applicationVersion: '1.0.0',
      applicationLegalese: 'A movie browser powered by The Movie Database.',
    );
  }
}
