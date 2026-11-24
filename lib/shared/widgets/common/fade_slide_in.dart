import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fades and slides its [child] up into place once, when first built.
///
/// Pass an [index] to stagger siblings (rails, grid cells): each one waits
/// [stagger] × index before starting, capped at [maxDelay] so long lists never
/// leave items invisible. The delay is folded into the animation curve, so no
/// timers are scheduled. Honours the platform "reduce motion" setting.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 380),
    this.stagger = const Duration(milliseconds: 50),
    this.maxDelay = const Duration(milliseconds: 300),
    this.offset = 16,
  });

  final Widget child;
  final int index;
  final Duration duration;
  final Duration stagger;
  final Duration maxDelay;

  /// Starting vertical offset in logical pixels.
  final double offset;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final delayMs = math.min(
      stagger.inMilliseconds * index,
      maxDelay.inMilliseconds,
    );
    final totalMs = delayMs + duration.inMilliseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      curve: Interval(delayMs / totalMs, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * offset),
          child: child,
        ),
      ),
    );
  }
}
