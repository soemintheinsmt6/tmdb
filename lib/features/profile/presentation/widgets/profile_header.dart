import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';

/// Avatar circle + display name + a single-line stat (e.g. favourites count).
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.subtitle,
  });

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cyan.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.cyan.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              IconsaxPlusBold.user,
              size: 44,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: AppTypography.sectionTitle.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.smallText.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
