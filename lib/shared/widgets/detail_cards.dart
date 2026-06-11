import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/shared/domain/cast_member.dart';
import 'package:tmdb/shared/domain/genre.dart';
import 'package:tmdb/shared/domain/poster_item.dart';
import 'package:tmdb/shared/widgets/poster_image.dart';
import 'package:tmdb/shared/widgets/rating_badge.dart';

/// Backdrop hero with a bottom fade, shared by the movie and TV detail screens.
class DetailHeader extends StatelessWidget {
  const DetailHeader({super.key, required this.backdropPath, this.heroTag});

  final String? backdropPath;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = ApiConstants.backdropUrl(backdropPath, size: 'original');
    Widget image = url.isEmpty
        ? Container(color: colors.surface)
        : CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: colors.surface),
            errorWidget: (_, __, ___) => Container(color: colors.surface),
          );
    if (heroTag != null) {
      image = Hero(
        tag: heroTag!,
        flightShuttleBuilder: _backdropFlightShuttle,
        child: image,
      );
    }
    return Stack(
      children: [
        AspectRatio(aspectRatio: 16 / 9, child: image),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.background.withValues(alpha: 0.0),
                  colors.background.withValues(alpha: 0.85),
                  colors.background,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _backdropFlightShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromContext,
  BuildContext toContext,
) {
  final pop = direction == HeroFlightDirection.pop;
  final tween = BorderRadiusTween(
    begin: pop ? BorderRadius.zero : BorderRadius.circular(16),
    end: pop ? BorderRadius.circular(16) : BorderRadius.zero,
  );
  final hero = (pop ? fromContext : toContext).widget as Hero;
  return AnimatedBuilder(
    animation: animation,
    builder: (_, __) => ClipRRect(
      borderRadius: tween.evaluate(animation) ?? BorderRadius.zero,
      child: hero.child,
    ),
  );
}

/// Poster + title/tagline + a rating badge, caller-supplied [metaChips], and
/// genre chips. The meta row differs per feature (runtime vs. seasons), so the
/// owning screen builds the [metaChips].
class DetailSummary extends StatelessWidget {
  const DetailSummary({
    super.key,
    required this.posterUrl,
    required this.title,
    required this.rating,
    required this.metaChips,
    required this.genres,
    this.tagline = '',
  });

  final String posterUrl;
  final String title;
  final String tagline;
  final String rating;
  final List<Widget> metaChips;
  final List<Genre> genres;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: PosterImage(url: posterUrl)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.sectionTitle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (tagline.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  tagline,
                  style: AppTypography.smallText.copyWith(
                    color: colors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  RatingBadge(rating: rating),
                  ...metaChips,
                ],
              ),
              if (genres.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final g in genres)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceMuted,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          g.name,
                          style: AppTypography.smallText.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Small icon + label chip used to compose a [DetailSummary]'s meta row.
class DetailMetaChip extends StatelessWidget {
  const DetailMetaChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.smallText.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

class DetailOverview extends StatelessWidget {
  const DetailOverview({super.key, required this.overview});

  final String overview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overview', style: AppTypography.subTitle),
        const SizedBox(height: 8),
        Text(
          overview.isEmpty ? 'No overview available.' : overview,
          style: AppTypography.bodyText.copyWith(
            color: context.colors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class DetailCastList extends StatelessWidget {
  const DetailCastList({
    super.key,
    required this.cast,
    this.horizontalPadding = 16,
  });

  final List<CastMember> cast;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const Text('Top Cast', style: AppTypography.subTitle),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: cast.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, index) {
              final c = cast[index];
              return SizedBox(width: 100, child: _CastTile(member: c));
            },
          ),
        ),
      ],
    );
  }
}

class _CastTile extends StatelessWidget {
  const _CastTile({required this.member});

  final CastMember member;

  @override
  Widget build(BuildContext context) {
    final url = member.profileUrl();
    final colors = context.colors;
    Widget fallback() => Container(
      color: colors.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(IconsaxPlusLinear.user, color: colors.textMuted),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: SizedBox(
            width: 80,
            height: 80,
            child: url.isEmpty
                ? fallback()
                : CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => fallback(),
                    errorWidget: (_, __, ___) => fallback(),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          member.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTypography.smallText.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          member.character,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTypography.labelSmall,
        ),
      ],
    );
  }
}

/// Horizontal rail of recommendation/similar posters. The [onTap] callback
/// routes to the owning feature's detail screen.
class DetailPosterRail extends StatelessWidget {
  const DetailPosterRail({
    super.key,
    required this.title,
    required this.items,
    required this.onTap,
    this.horizontalPadding = 16,
  });

  final String title;
  final List<PosterItem> items;
  final void Function(PosterItem item) onTap;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Text(title, style: AppTypography.subTitle),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, index) {
              final item = items[index];
              return SizedBox(
                width: 130,
                child: GestureDetector(
                  onTap: () => onTap(item),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PosterImage(url: item.posterUrl()),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.smallText.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ctx.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
