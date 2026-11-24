import 'package:flutter/material.dart';
import 'package:tmdb/shared/widgets/common/app_error_view.dart';
import 'package:tmdb/shared/widgets/skeletons/rail_feed_skeleton.dart';

/// Body of an [ImmersiveFeedScaffold] feed: crossfades between the skeleton,
/// an error view and the loaded feed.
///
/// The skeleton and error view are pushed below the transparent app bar; the
/// loaded feed receives the bar's height as `topInset` so its hero can extend
/// up beneath it.
class FeedStateSwitcher extends StatelessWidget {
  const FeedStateSwitcher({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.loadedBuilder,
  });

  final bool isLoading;

  /// Non-null when the feed failed to load.
  final String? errorMessage;
  final VoidCallback onRetry;
  final Widget Function(BuildContext context, double topInset) loadedBuilder;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final Widget child;
    if (isLoading) {
      child = Padding(
        key: const ValueKey('feed-loading'),
        padding: EdgeInsets.only(top: topInset),
        // Stop the skeleton's ListView re-applying the inset itself.
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: const RailFeedSkeleton(),
        ),
      );
    } else if (errorMessage != null) {
      child = Padding(
        key: const ValueKey('feed-error'),
        padding: EdgeInsets.only(top: topInset),
        child: AppErrorView(message: errorMessage!, onRetry: onRetry),
      );
    } else {
      child = KeyedSubtree(
        key: const ValueKey('feed-loaded'),
        child: loadedBuilder(context, topInset),
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: child,
    );
  }
}
