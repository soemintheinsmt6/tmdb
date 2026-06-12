import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_detail/movie_detail_screen.dart';
import 'package:tmdb/features/people/domain/entities/person.dart';
import 'package:tmdb/features/people/domain/entities/person_credit.dart';
import 'package:tmdb/features/tv/presentation/screens/tv_detail/tv_detail_screen.dart';
import 'package:tmdb/shared/widgets/detail_cards.dart';

/// Profile photo + name + known-for department + vital-stat chips. The person
/// screen has no backdrop, so this header stands in for the movie/TV summary.
class PersonHeader extends StatelessWidget {
  const PersonHeader({super.key, required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final birthday = _formatBirthday(person.birthday);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: _ProfilePhoto(url: person.profileUrl())),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                person.name,
                style: AppTypography.sectionTitle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (person.knownForDepartment.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  person.knownForDepartment,
                  style: AppTypography.smallText.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (birthday != null)
                    DetailMetaChip(
                      icon: IconsaxPlusLinear.calendar_1,
                      label: birthday,
                    ),
                  // Age is only meaningful for the living; a deceased person's
                  // `age` would read as age-at-death without context, so omit it.
                  if (person.deathday == null && person.age != null)
                    DetailMetaChip(
                      icon: IconsaxPlusLinear.cake,
                      label: 'Age ${person.age}',
                    ),
                  if (person.placeOfBirth != null &&
                      person.placeOfBirth!.isNotEmpty)
                    DetailMetaChip(
                      icon: IconsaxPlusLinear.location,
                      label: person.placeOfBirth!,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// `"1963-12-18"` → `"Dec 18, 1963"`; falls back to the raw string when it
  /// can't be parsed, and to `null` when absent.
  static String? _formatBirthday(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final parsed = DateTime.tryParse(iso);
    return parsed == null ? iso : DateFormat.yMMMd().format(parsed);
  }
}

/// Rounded profile image with a person-shaped fallback (mirrors the cast tile).
class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget fallback() => Container(
      color: colors.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(IconsaxPlusLinear.user, color: colors.textMuted, size: 40),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: url.isEmpty
            ? fallback()
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => fallback(),
                errorWidget: (_, __, ___) => fallback(),
              ),
      ),
    );
  }
}

/// "Biography" section with a Read more / Read less toggle for long bios.
class PersonBiography extends StatefulWidget {
  const PersonBiography({super.key, required this.biography});

  final String biography;

  @override
  State<PersonBiography> createState() => _PersonBiographyState();
}

class _PersonBiographyState extends State<PersonBiography> {
  static const _collapsedLines = 6;
  static const _toggleThreshold = 280;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bio = widget.biography;
    final canToggle = bio.length > _toggleThreshold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Biography', style: AppTypography.subTitle),
        const SizedBox(height: 8),
        Text(
          bio.isEmpty ? 'No biography available.' : bio,
          maxLines: canToggle && !_expanded ? _collapsedLines : null,
          overflow: canToggle && !_expanded
              ? TextOverflow.ellipsis
              : TextOverflow.clip,
          style: AppTypography.bodyText.copyWith(
            color: colors.textSecondary,
            height: 1.6,
          ),
        ),
        if (canToggle)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerLeft,
            ),
            child: Text(_expanded ? 'Read less' : 'Read more'),
          ),
      ],
    );
  }
}

/// Combined movie + TV filmography as a poster rail. Reuses the shared
/// [DetailPosterRail] and routes each poster to the matching detail screen.
class PersonFilmography extends StatelessWidget {
  const PersonFilmography({
    super.key,
    required this.credits,
    this.horizontalPadding = 16,
  });

  final List<PersonCredit> credits;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return DetailPosterRail(
      title: 'Filmography',
      items: credits,
      horizontalPadding: horizontalPadding,
      onTap: (item) {
        final credit = item as PersonCredit;
        switch (credit.mediaType) {
          case CreditMediaType.movie:
            unawaited(
              pushView(
                context,
                MovieDetailScreen(movieId: credit.id, title: credit.title),
              ),
            );
          case CreditMediaType.tv:
            unawaited(
              pushView(
                context,
                TvDetailScreen(tvShowId: credit.id, title: credit.title),
              ),
            );
          case null:
            break;
        }
      },
    );
  }
}
