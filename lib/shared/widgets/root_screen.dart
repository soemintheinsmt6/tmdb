import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/features/discover/presentation/screens/discover_screen.dart';
import 'package:tmdb/features/home/presentation/screens/home_screen.dart';
import 'package:tmdb/features/library/presentation/screens/library_screen.dart';
import 'package:tmdb/features/profile/presentation/screens/profile_screen.dart';
import 'package:tmdb/features/tv/presentation/screens/tv_home/tv_screen.dart';

/// One bottom-nav destination, described once for every bar flavour.
class _TabSpec {
  const _TabSpec({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.symbol,
    required this.selectedSymbol,
  });

  final String label;

  /// Iconsax glyphs for the Flutter-drawn bars (Material / Cupertino).
  final IconData icon;
  final IconData selectedIcon;

  /// SF Symbol names for the native iOS bar.
  final String symbol;
  final String selectedSymbol;
}

const List<_TabSpec> _tabSpecs = [
  _TabSpec(
    label: 'Home',
    icon: IconsaxPlusLinear.category_2,
    selectedIcon: IconsaxPlusBold.category_2,
    symbol: 'house',
    selectedSymbol: 'house.fill',
  ),
  _TabSpec(
    label: 'Discover',
    icon: IconsaxPlusLinear.discover_1,
    selectedIcon: IconsaxPlusBold.discover,
    symbol: 'safari',
    selectedSymbol: 'safari.fill',
  ),
  _TabSpec(
    label: 'Series',
    icon: IconsaxPlusLinear.video_square,
    selectedIcon: IconsaxPlusBold.video_square,
    symbol: 'play.tv',
    selectedSymbol: 'play.tv.fill',
  ),
  _TabSpec(
    label: 'Library',
    icon: IconsaxPlusLinear.archive_1,
    selectedIcon: IconsaxPlusBold.archive_1,
    symbol: 'books.vertical',
    selectedSymbol: 'books.vertical.fill',
  ),
  _TabSpec(
    label: 'Profile',
    icon: IconsaxPlusLinear.user,
    selectedIcon: IconsaxPlusBold.user,
    symbol: 'person',
    selectedSymbol: 'person.fill',
  ),
];

/// App shell with a bottom navigation bar. Tabs are built lazily on first
/// selection and kept alive afterwards so their state survives switches.
///
/// The bar is platform-native where possible: a UIKit Liquid Glass tab bar on
/// iOS 26+, a [CupertinoTabBar] on older iOS, and a Material [NavigationBar]
/// everywhere else.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  static final int _tabCount = _tabSpecs.length;

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

  void _select(int index) => setState(() => _index = index);

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
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
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
        // The native bar renders only on iOS 26+; it shows [fallback] while
        // probing support and wherever Liquid Glass is unavailable.
        bottomNavigationBar: NativeGlassNavBar(
          currentIndex: _index,
          onTap: _select,
          tintColor: AppColors.cyan,
          tabs: [
            for (final spec in _tabSpecs)
              NativeGlassNavBarItem(
                label: spec.label,
                symbol: spec.symbol,
                selectedSymbol: spec.selectedSymbol,
              ),
          ],
          fallback: isIOS
              ? _buildCupertinoBar(context)
              : _buildMaterialBar(context),
        ),
      ),
    );
  }

  /// Pre-Liquid-Glass iOS: the classic translucent UIKit-style tab bar.
  Widget _buildCupertinoBar(BuildContext context) {
    final colors = context.colors;
    return CupertinoTabBar(
      currentIndex: _index,
      onTap: _select,
      activeColor: AppColors.cyan,
      inactiveColor: colors.textMuted,
      backgroundColor: colors.surface.withValues(alpha: 0.92),
      border: Border(top: BorderSide(color: colors.divider, width: 0.5)),
      items: [
        for (final spec in _tabSpecs)
          BottomNavigationBarItem(
            icon: Icon(spec.icon),
            activeIcon: Icon(spec.selectedIcon),
            label: spec.label,
          ),
      ],
    );
  }

  /// Android and other platforms: Material 3 navigation bar.
  Widget _buildMaterialBar(BuildContext context) {
    final colors = context.colors;
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        height: 68,
        indicatorColor: AppColors.cyan.withValues(alpha: 0.16),
        indicatorShape: const StadiumBorder(),
        overlayColor: WidgetStatePropertyAll(
          AppColors.cyan.withValues(alpha: 0.08),
        ),
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
        onDestinationSelected: _select,
        backgroundColor: colors.surface,
        animationDuration: const Duration(milliseconds: 350),
        destinations: [
          for (final spec in _tabSpecs)
            NavigationDestination(
              icon: Icon(spec.icon, color: colors.textMuted),
              selectedIcon: Icon(spec.selectedIcon, color: AppColors.cyan),
              label: spec.label,
            ),
        ],
      ),
    );
  }
}
