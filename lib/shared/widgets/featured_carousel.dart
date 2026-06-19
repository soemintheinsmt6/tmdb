import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/shared/domain/poster_item.dart';
import 'package:tmdb/shared/widgets/featured_hero.dart';

/// Auto-advancing hero carousel for the trending titles at the top of the home
/// and series screens. Loops seamlessly (an unbounded [PageView] centred far
/// from zero) and shows page-indicator dots. A single item renders as a static
/// hero with no timer.
class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({
    super.key,
    required this.items,
    required this.onTap,
    this.heroTag,
    this.label = 'TRENDING',
    this.interval = const Duration(seconds: 5),
  });

  final List<PosterItem> items;
  final void Function(PosterItem item) onTap;

  /// Builds the [Hero] tag for an item, enabling a shared transition into its
  /// detail screen. Only the centred slide is tagged, so the looping PageView's
  /// cached neighbours can never duplicate a tag.
  final Object? Function(PosterItem item)? heroTag;
  final String label;
  final Duration interval;

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  static const double _aspectRatio = 16 / 10;

  // Start far from 0 so the carousel scrolls "infinitely" forward while still
  // landing on a real index of 0.
  late final PageController _controller = PageController(
    initialPage: widget.items.length * 1000,
  );
  Timer? _timer;
  int _index = 0;

  bool get _looping => widget.items.length > 1;

  @override
  void initState() {
    super.initState();
    if (_looping) _scheduleNext();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleNext() {
    _timer?.cancel();
    _timer = Timer(widget.interval, () {
      if (!mounted || !_controller.hasClients) return;
      unawaited(
        _controller.nextPage(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        ),
      );
    });
  }

  void _onPageChanged(int page) {
    setState(() => _index = page % widget.items.length);
    // Reschedule after every settle (auto or manual swipe) so a swipe resets
    // the dwell time rather than jumping immediately.
    if (_looping) _scheduleNext();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    if (!_looping) {
      final item = widget.items.first;
      return AspectRatio(
        aspectRatio: _aspectRatio,
        child: FeaturedHero(
          item: item,
          onTap: () => widget.onTap(item),
          label: widget.label,
          heroTag: widget.heroTag?.call(item),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, page) {
              final realIndex = page % widget.items.length;
              final item = widget.items[realIndex];
              return FeaturedHero(
                item: item,
                onTap: () => widget.onTap(item),
                label: widget.label,
                // Tag only the centred slide so cached neighbours don't share a
                // tag with it during a hero flight.
                heroTag: realIndex == _index
                    ? widget.heroTag?.call(item)
                    : null,
              );
            },
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: _Dots(count: widget.items.length, index: _index),
          ),
        ],
      ),
    );
  }
}

/// Page-indicator dots; the active dot is wider and cyan.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(left: 5),
            width: i == index ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == index
                  ? AppColors.cyan
                  : AppColors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
