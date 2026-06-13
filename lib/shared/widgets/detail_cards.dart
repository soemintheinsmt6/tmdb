import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/shared/domain/cast_member.dart';
import 'package:tmdb/shared/domain/genre.dart';
import 'package:tmdb/shared/domain/media_image.dart';
import 'package:tmdb/shared/domain/poster_item.dart';
import 'package:tmdb/shared/domain/review.dart';
import 'package:tmdb/shared/domain/video.dart';
import 'package:tmdb/shared/widgets/image_gallery_viewer.dart';
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
    this.onTap,
    this.horizontalPadding = 16,
  });

  final List<CastMember> cast;

  /// Routes a tapped cast member (e.g. to the person detail screen). When
  /// `null` the tiles render as plain, non-interactive avatars.
  final void Function(CastMember member)? onTap;
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
              return SizedBox(
                width: 100,
                child: _CastTile(member: c, onTap: onTap),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CastTile extends StatelessWidget {
  const _CastTile({required this.member, this.onTap});

  final CastMember member;
  final void Function(CastMember member)? onTap;

  @override
  Widget build(BuildContext context) {
    final url = member.profileUrl();
    final colors = context.colors;
    Widget fallback() => Container(
      color: colors.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(IconsaxPlusLinear.user, color: colors.textMuted),
    );
    final tile = Column(
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

    if (onTap == null) return tile;
    return InkWell(
      onTap: () => onTap!(member),
      borderRadius: BorderRadius.circular(12),
      child: tile,
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

/// Horizontal rail of 16:9 video thumbnails (trailers, teasers, clips). Tapping
/// a tile invokes [onTap] with the chosen [Video]. Shared by the movie and TV
/// detail screens; renders nothing when [videos] is empty.
class DetailVideoRail extends StatelessWidget {
  const DetailVideoRail({
    super.key,
    required this.videos,
    required this.onTap,
    this.title = 'Trailers & Clips',
    this.horizontalPadding = 16,
  });

  final List<Video> videos;
  final void Function(Video video) onTap;
  final String title;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Text(title, style: AppTypography.subTitle),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: videos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final video = videos[index];
              return SizedBox(
                width: 220,
                child: _VideoTile(video: video, onTap: () => onTap(video)),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.video, required this.onTap});

  final Video video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget fallback() => Container(
      color: colors.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(IconsaxPlusLinear.video_play, color: colors.textMuted),
    );
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  video.thumbnailUrl.isEmpty
                      ? fallback()
                      : CachedNetworkImage(
                          imageUrl: video.thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: colors.surfaceMuted),
                          errorWidget: (_, __, ___) => fallback(),
                        ),
                  const DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black26),
                  ),
                  const Center(
                    child: Icon(
                      IconsaxPlusBold.video_play,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  if (video.type.isNotEmpty)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          video.type,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            video.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.smallText.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical list of user [reviews] with author, rating, and expandable text.
/// Shared by the movie and TV detail screens; renders nothing when empty.
class DetailReviewsSection extends StatelessWidget {
  const DetailReviewsSection({
    super.key,
    required this.reviews,
    this.horizontalPadding = 16,
  });

  final List<Review> reviews;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reviews', style: AppTypography.subTitle),
          const SizedBox(height: 12),
          for (final review in reviews) ...[
            _ReviewCard(review: review),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final review = widget.review;
    // Roughly six lines of body text; only long reviews get a toggle.
    final isLong = review.content.length > 280;
    final subtitle = [
      if (review.username.isNotEmpty) '@${review.username}',
      if (review.year != null) review.year,
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(review: review),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyText.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              if (review.formattedRating.isNotEmpty) ...[
                const SizedBox(width: 8),
                RatingBadge(rating: review.formattedRating, compact: true),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.content,
            maxLines: _expanded ? null : 5,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: AppTypography.bodyText.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          if (isLong)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _expanded ? 'Read less' : 'Read more',
                  style: AppTypography.smallText.copyWith(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = review.avatarUrl;
    Widget fallback() => Container(
      color: colors.surfaceMuted,
      alignment: Alignment.center,
      child: Text(
        review.initial,
        style: AppTypography.bodyText.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: SizedBox(
        width: 40,
        height: 40,
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

/// Horizontal rail of 16:9 backdrop thumbnails. Tapping one opens the
/// full-screen [ImageGalleryViewer] at that index. Shared by the movie and TV
/// detail screens; renders nothing when [images] is empty.
class DetailImageGallery extends StatelessWidget {
  const DetailImageGallery({
    super.key,
    required this.images,
    this.title = 'Gallery',
    this.horizontalPadding = 16,
  });

  final List<MediaImage> images;
  final String title;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Text(title, style: AppTypography.subTitle),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              final image = images[index];
              return GestureDetector(
                onTap: () => openImageGallery(
                  context,
                  images: images,
                  initialIndex: index,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: image.url(),
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: colors.surfaceMuted),
                      errorWidget: (_, __, ___) => Container(
                        color: colors.surfaceMuted,
                        alignment: Alignment.center,
                        child: Icon(
                          IconsaxPlusLinear.gallery,
                          color: colors.textMuted,
                        ),
                      ),
                    ),
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
