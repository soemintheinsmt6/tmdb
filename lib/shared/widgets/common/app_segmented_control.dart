import 'package:flutter/material.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';

/// One option in an [AppSegmentedControl].
class AppSegment<T> {
  const AppSegment({required this.value, required this.label});

  final T value;
  final String label;
}

/// Pill-shaped segmented control with a sliding cyan thumb.
///
/// Segments share the width equally; the selected one is marked by a thumb
/// that animates between positions instead of a hard divider and fill swap.
class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.height = 40,
  }) : assert(segments.length >= 2);

  final List<AppSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final double height;

  static const _inset = 4.0;
  static const _duration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedIndex = segments
        .indexWhere((s) => s.value == selected)
        .clamp(0, segments.length - 1);
    final selectedText = isDark ? AppColors.navy : AppColors.white;

    return Container(
      height: height,
      padding: const EdgeInsets.all(_inset),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          // Sliding thumb.
          AnimatedAlign(
            duration: _duration,
            curve: Curves.easeOutCubic,
            alignment: Alignment(
              -1 + 2 * selectedIndex / (segments.length - 1),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / segments.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.cyan,
                  borderRadius: BorderRadius.circular(height / 2 - _inset),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyan.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < segments.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == selectedIndex,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(height / 2 - _inset),
                      onTap: i == selectedIndex
                          ? null
                          : () => onChanged(segments[i].value),
                      child: Center(
                        // Plus Jakarta Sans has a tall ascent (1038 vs 222
                        // descent), so glyphs sit low in their line box; lift
                        // the label ~0.5px to centre it optically.
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: AnimatedDefaultTextStyle(
                            duration: _duration,
                            style: AppTypography.bodyText.copyWith(
                              fontWeight: FontWeight.w600,
                              // Tight line box with even leading so the
                              // body-text line height doesn't push glyphs down.
                              height: 1,
                              leadingDistribution: TextLeadingDistribution.even,
                              color: i == selectedIndex
                                  ? selectedText
                                  : colors.textSecondary,
                            ),
                            child: Text(
                              segments[i].label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
