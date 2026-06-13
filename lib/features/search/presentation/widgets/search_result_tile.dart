import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/features/search/domain/entities/search_result.dart';
import 'package:tmdb/shared/widgets/poster_image.dart';

/// A single multi-search row: thumbnail, title, a media-type chip and a
/// type-specific subtitle (year • rating for titles, known-for dept for
/// people). Tapping routes via the caller's [onTap].
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.result,
    required this.onTap,
  });

  final SearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: PosterImage(url: result.imageUrl(), borderRadius: 8),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _MediaTypeChip(label: result.mediaTypeLabel),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _subtitle(result),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.smallText.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              IconsaxPlusLinear.arrow_right_3,
              size: 18,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  /// `"1999  •  ★ 8.2"` for titles, the known-for department for people, or
  /// `"—"` when nothing is known.
  String _subtitle(SearchResult r) {
    if (r.mediaType == SearchMediaType.person) {
      return r.knownForDepartment.isEmpty ? '—' : r.knownForDepartment;
    }
    final parts = <String>[
      if (r.year != null) r.year!,
      if (r.formattedRating != null) '★ ${r.formattedRating}',
    ];
    return parts.isEmpty ? '—' : parts.join('  •  ');
  }
}

/// Small pill labelling the result's media type (Movie / TV / Person).
class _MediaTypeChip extends StatelessWidget {
  const _MediaTypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.cyan.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.smallText.copyWith(
          color: AppColors.cyan,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          height: 1,
        ),
      ),
    );
  }
}
