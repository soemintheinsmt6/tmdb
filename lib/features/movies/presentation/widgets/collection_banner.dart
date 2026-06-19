import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/movies/domain/entities/movie_collection.dart';
import 'package:tmdb/features/movies/presentation/screens/collection/collection_screen.dart';

/// Wide backdrop banner on movie detail announcing the franchise a film belongs
/// to ("Part of the … Collection"). Tapping opens the full [CollectionScreen].
class CollectionBanner extends StatelessWidget {
  const CollectionBanner({
    super.key,
    required this.collection,
    this.horizontalPadding = 16,
  });

  final MovieCollectionRef collection;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final backdrop = collection.backdropUrl();
    final heroTag = 'collection-backdrop-${collection.id}';

    final Widget image = backdrop.isEmpty
        ? Container(color: colors.surfaceMuted)
        : CachedNetworkImage(
            imageUrl: backdrop,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: colors.surfaceMuted),
            errorWidget: (_, __, ___) => Container(color: colors.surfaceMuted),
          );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GestureDetector(
        onTap: () => pushView(
          context,
          CollectionScreen(
            collectionId: collection.id,
            title: collection.name,
            seedBackdropPath: collection.backdropPath,
            heroTag: heroTag,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 16 / 7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Flies into the collection screen's backdrop header.
                Hero(tag: heroTag, child: image),
                // Left-weighted scrim keeps the label legible over any art.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.black87, Colors.black26],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PART OF',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              collection.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.subTitle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        IconsaxPlusLinear.arrow_right_3,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
