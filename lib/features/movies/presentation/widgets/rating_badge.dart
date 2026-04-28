import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';

/// Pill-shaped rating badge styled after the TMDB user score chip.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, this.compact = false});

  final String rating;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _ratingColor(context, rating);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(IconsaxPlusBold.star_1, size: compact ? 11 : 13, color: color),
          SizedBox(width: compact ? 3 : 4),
          Text(
            rating,
            style: AppTypography.smallText.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 11 : 12,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Color _ratingColor(BuildContext context, String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return context.colors.textMuted;
    if (parsed >= 7.5) return AppColors.success;
    if (parsed >= 5) return AppColors.warning;
    return AppColors.error;
  }
}
