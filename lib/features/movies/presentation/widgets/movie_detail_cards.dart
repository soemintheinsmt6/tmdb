import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/movies/domain/entities/cast_member.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';
import 'package:tmdb/features/movies/domain/entities/movie_detail.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_detail/movie_detail_screen.dart';
import 'package:tmdb/features/movies/presentation/widgets/movie_poster.dart';
import 'package:tmdb/features/movies/presentation/widgets/rating_badge.dart';

class DetailHeader extends StatelessWidget {
  const DetailHeader({super.key, required this.detail});

  final MovieDetail detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: detail.backdropUrl().isEmpty
              ? Container(color: colors.surface)
              : CachedNetworkImage(
                  imageUrl: detail.backdropUrl(),
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: colors.surface),
                  errorWidget: (_, __, ___) => Container(color: colors.surface),
                ),
        ),
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

class DetailSummary extends StatelessWidget {
  const DetailSummary({super.key, required this.detail});

  final MovieDetail detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: MoviePoster(url: detail.posterUrl())),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.title,
                style: AppTypography.sectionTitle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (detail.tagline.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  detail.tagline,
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
                  RatingBadge(rating: detail.formattedRating),
                  _MetaChip(
                    icon: IconsaxPlusLinear.calendar_1,
                    label: detail.releaseYear ?? '—',
                  ),
                  _MetaChip(
                    icon: IconsaxPlusLinear.clock_1,
                    label: detail.formattedRuntime,
                  ),
                ],
              ),
              if (detail.genres.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final g in detail.genres)
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

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
          style: AppTypography.smallText.copyWith(
            color: colors.textSecondary,
          ),
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
        Text('Overview', style: AppTypography.subTitle),
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
          child: Text('Top Cast', style: AppTypography.subTitle),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: SizedBox(
            width: 80,
            height: 80,
            child: url.isEmpty
                ? Container(
                    color: colors.surfaceMuted,
                    alignment: Alignment.center,
                    child: Icon(
                      IconsaxPlusLinear.user,
                      color: colors.textMuted,
                    ),
                  )
                : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
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

class DetailRecommendations extends StatelessWidget {
  const DetailRecommendations({
    super.key,
    required this.movies,
    this.horizontalPadding = 16,
  });

  final List<Movie> movies;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Text('Similar Movies', style: AppTypography.subTitle),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: movies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, index) {
              final m = movies[index];
              return SizedBox(
                width: 130,
                child: GestureDetector(
                  onTap: () => pushView(
                    context,
                    MovieDetailScreen(movieId: m.id, title: m.title),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MoviePoster(url: m.posterUrl()),
                      const SizedBox(height: 6),
                      Text(
                        m.title,
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
