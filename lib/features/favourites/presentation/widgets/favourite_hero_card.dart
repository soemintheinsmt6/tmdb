import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/features/favourites/domain/entities/favourite_item.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:tmdb/features/favourites/presentation/favourite_navigation.dart';
import 'package:tmdb/shared/widgets/rating_badge.dart';

/// Full-width 16:9 card with the backdrop as a hero image, a heart in the
/// top-right, a media-type chip in the top-left, and title / rating / year
/// overlaid at the bottom. Routes to the movie or TV detail screen based on
/// [FavouriteItem.mediaType].
class FavouriteHeroCard extends StatelessWidget {
  const FavouriteHeroCard({super.key, required this.item});

  final FavouriteItem item;

  @override
  Widget build(BuildContext context) {
    final hasBackdrop =
        item.backdropPath != null && item.backdropPath!.isNotEmpty;
    final heroTag = hasBackdrop ? 'favourite-backdrop-${item.storageKey}' : null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          _BackgroundImage(item: item, heroTag: heroTag),
          const Positioned.fill(child: _BottomGradient()),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => openFavouriteDetail(context, item, heroTag: heroTag),
              ),
            ),
          ),
          Positioned(top: 10, left: 12, child: _TypeChip(type: item.mediaType)),
          Positioned(top: 8, right: 8, child: _RemoveButton(item: item)),
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: _CardFooter(item: item),
          ),
        ],
      ),
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage({required this.item, required this.heroTag});

  final FavouriteItem item;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasBackdrop =
        item.backdropPath != null && item.backdropPath!.isNotEmpty;
    final imageUrl = hasBackdrop
        ? item.backdropUrl(size: 'w780')
        : item.posterUrl(size: 'w500');

    final image = imageUrl.isEmpty
        ? Container(color: colors.surfaceMuted)
        : CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: colors.surfaceMuted),
            errorWidget: (_, __, ___) => Container(color: colors.surfaceMuted),
          );

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: heroTag != null ? Hero(tag: heroTag!, child: image) : image,
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0),
              Colors.black.withValues(alpha: 0.55),
              Colors.black.withValues(alpha: 0.85),
            ],
            stops: const [0.45, 0.75, 1.0],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final MediaType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type == MediaType.movie ? 'MOVIE' : 'TV',
        style: AppTypography.smallText.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter({required this.item});

  final FavouriteItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.subTitle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            RatingBadge(rating: item.formattedRating, compact: true),
            const SizedBox(width: 10),
            const Icon(
              IconsaxPlusLinear.calendar_1,
              size: 13,
              color: Colors.white70,
            ),
            const SizedBox(width: 4),
            Text(
              item.year ?? '—',
              style: AppTypography.smallText.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.item});

  final FavouriteItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: 'Remove from favourites',
        iconSize: 20,
        visualDensity: VisualDensity.compact,
        icon: const Icon(IconsaxPlusBold.heart, color: AppColors.cyan),
        onPressed: () =>
            context.read<FavouritesCubit>().remove(item.mediaType, item.id),
      ),
    );
  }
}
