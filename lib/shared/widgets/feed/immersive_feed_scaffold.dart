import 'package:flutter/material.dart';
import 'package:tmdb/core/theme/app_colors.dart';

/// Scaffold for an editorial feed tab (home, series) whose hero is drawn
/// beneath the app bar. The bar is transparent at rest and fades to solid navy
/// as the feed scrolls past the backdrop.
///
/// The body is laid out behind the bar, so it sees the bar + status bar height
/// as `MediaQuery.paddingOf(context).top` — see [FeedStateSwitcher] for the
/// matching body.
class ImmersiveFeedScaffold extends StatefulWidget {
  const ImmersiveFeedScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  final String title;
  final Widget body;
  final List<Widget> actions;

  @override
  State<ImmersiveFeedScaffold> createState() => _ImmersiveFeedScaffoldState();
}

class _ImmersiveFeedScaffoldState extends State<ImmersiveFeedScaffold> {
  /// Scroll distance over which the app bar goes from clear to solid.
  static const double _fadeDistance = 140;

  double _barOpacity = 0;

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final opacity = (notification.metrics.pixels / _fadeDistance).clamp(
      0.0,
      1.0,
    );
    if (opacity != _barOpacity) setState(() => _barOpacity = opacity);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        backgroundColor: AppColors.navy.withValues(alpha: _barOpacity),
        scrolledUnderElevation: 0,
        title: Text(widget.title),
        actions: widget.actions,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: widget.body,
      ),
    );
  }
}
