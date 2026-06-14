import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:tmdb/core/extensions/double_rating.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';

/// Star-based rating used on the detail screens.
///
/// Maps a 0–10 [voteAverage] onto a 5-star row (each star = 2 points, with
/// fractional fill) and shows the numeric score plus the total [voteCount]
/// beside it. An alternative presentation to the pill-shaped `RatingBadge`.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.voteAverage,
    required this.voteCount,
    this.starSize = 18,
  });

  /// TMDB vote average on a 0–10 scale.
  final double voteAverage;

  /// Total number of votes; `0` renders as a "not rated" state.
  final int voteCount;

  /// Side length of each star icon.
  final double starSize;

  static final NumberFormat _votesFormat = NumberFormat.compact();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rated = voteCount > 0;
    final starValue = (voteAverage / 2).clamp(0.0, 5.0);

    final muted = AppTypography.smallText.copyWith(color: colors.textMuted);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < 5; i++)
          Padding(
            padding: EdgeInsets.only(right: i == 4 ? 0 : 3),
            child: _Star(
              fill: rated ? (starValue - i).clamp(0.0, 1.0) : 0,
              size: starSize,
            ),
          ),
        const SizedBox(width: 10),
        Flexible(
          child: rated
              ? Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: voteAverage.rating,
                        style: AppTypography.subTitle.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      TextSpan(text: ' /10', style: muted),
                      TextSpan(
                        text: '  ·  ${_votesFormat.format(voteCount)} '
                            '${voteCount == 1 ? 'vote' : 'votes'}',
                        style: muted,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : Text(
                  'Not rated yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
        ),
      ],
    );
  }
}

/// A single star drawn as a muted track with a fractional gold fill clipped
/// left-to-right, so half-point scores read accurately.
class _Star extends StatelessWidget {
  const _Star({required this.fill, required this.size});

  /// 0 = empty, 1 = full, fractional values fill from the left.
  final double fill;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(
          IconsaxPlusBold.star_1,
          size: size,
          color: AppColors.warning.withValues(alpha: 0.22),
        ),
        if (fill > 0)
          ClipRect(
            clipper: _FractionClipper(fill),
            child: Icon(
              IconsaxPlusBold.star_1,
              size: size,
              color: AppColors.warning,
            ),
          ),
      ],
    );
  }
}

class _FractionClipper extends CustomClipper<Rect> {
  const _FractionClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_FractionClipper oldClipper) =>
      oldClipper.fraction != fraction;
}
