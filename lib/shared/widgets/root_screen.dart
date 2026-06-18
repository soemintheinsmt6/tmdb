import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/features/discover/presentation/screens/discover_screen.dart';
import 'package:tmdb/features/home/presentation/screens/home_screen.dart';
import 'package:tmdb/features/library/presentation/screens/library_screen.dart';
import 'package:tmdb/features/profile/presentation/screens/profile_screen.dart';
import 'package:tmdb/features/tv/presentation/screens/tv_home/tv_screen.dart';

/// App shell with a bottom navigation bar. Tabs are built lazily on first
/// selection and kept alive afterwards so their state survives switches.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  static const int _tabCount = 5;

  int _index = 0;
  final List<Widget?> _tabs = List.filled(_tabCount, null);

  /// One scroll controller per tab. Each tab scopes its lists to its own
  /// controller (see [_buildTab]) so the kept-alive tabs never contend over a
  /// single shared one. The active tab's controller is also exposed at the
  /// root (see [build]) so an iOS status-bar tap — which the outer [Scaffold]
  /// dispatches to the ambient [PrimaryScrollController] — scrolls the visible
  /// tab back to the top.
  final List<ScrollController> _scrollControllers = List.generate(
    _tabCount,
    (_) => ScrollController(),
  );

  @override
  void dispose() {
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildTab(int index) {
    final tab = _tabs[index] ??= switch (index) {
      0 => const HomeScreen(),
      1 => const DiscoverScreen(),
      2 => const TvScreen(),
      3 => const LibraryScreen(),
      4 => const ProfileScreen(),
      _ => const SizedBox.shrink(),
    };
    // Scope each tab to its own controller so its lists attach independently
    // of the other kept-alive tabs.
    return PrimaryScrollController(
      controller: _scrollControllers[index],
      child: tab,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PrimaryScrollController(
      // The outer Scaffold owns the iOS status-bar tap target; expose the
      // active tab's controller here so the tap scrolls the visible list.
      controller: _scrollControllers[_index],
      child: Scaffold(
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
                icon: Icon(
                  IconsaxPlusLinear.category_2,
                  color: colors.textMuted,
                ),
                selectedIcon: const Icon(
                  IconsaxPlusBold.category_2,
                  color: AppColors.cyan,
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(
                  IconsaxPlusLinear.discover_1,
                  color: colors.textMuted,
                ),
                selectedIcon: const Icon(
                  IconsaxPlusBold.discover,
                  color: AppColors.cyan,
                ),
                label: 'Discover',
              ),
              NavigationDestination(
                icon: Icon(
                  IconsaxPlusLinear.video_square,
                  color: colors.textMuted,
                ),
                selectedIcon: const Icon(
                  IconsaxPlusBold.video_square,
                  color: AppColors.cyan,
                ),
                label: 'Series',
              ),
              NavigationDestination(
                icon: Icon(
                  IconsaxPlusLinear.archive_1,
                  color: colors.textMuted,
                ),
                selectedIcon: const Icon(
                  IconsaxPlusBold.archive_1,
                  color: AppColors.cyan,
                ),
                label: 'Library',
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
      ),
    );
  }
}
