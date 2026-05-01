import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/features/favourites/presentation/screens/favourite_screen.dart';
import 'package:tmdb/features/movies/presentation/screens/home/home_screen.dart';
import 'package:tmdb/features/profile/presentation/screens/profile_screen.dart';

/// App shell with a bottom navigation bar. Tabs are built lazily on first
/// selection and kept alive afterwards so their state survives switches.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;
  final List<Widget?> _tabs = List.filled(3, null);

  Widget _buildTab(int index) {
    return _tabs[index] ??= switch (index) {
      0 => const HomeScreen(),
      1 => const FavouriteScreen(),
      2 => const ProfileScreen(),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: List.generate(_tabs.length, (i) {
          if (i == _index || _tabs[i] != null) return _buildTab(i);
          return const SizedBox.shrink();
        }),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.transparent,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: states.contains(WidgetState.selected)
                  ? AppColors.cyan
                  : colors.textMuted,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: colors.surface,
          destinations: [
            NavigationDestination(
              icon: Icon(IconsaxPlusLinear.category_2, color: colors.textMuted),
              selectedIcon: const Icon(
                IconsaxPlusBold.category_2,
                color: AppColors.cyan,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(IconsaxPlusLinear.heart, color: colors.textMuted),
              selectedIcon: const Icon(
                IconsaxPlusBold.heart,
                color: AppColors.cyan,
              ),
              label: 'Favourites',
            ),
            NavigationDestination(
              icon: Icon(IconsaxPlusLinear.user, color: colors.textMuted),
              selectedIcon: const Icon(
                IconsaxPlusBold.user,
                color: AppColors.cyan,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
