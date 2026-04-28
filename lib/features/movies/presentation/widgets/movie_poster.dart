import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/theme/app_colors.dart';

/// Renders a TMDB poster URL with rounded corners, placeholder, and error
/// fallback. Pass an empty string for [url] to show the placeholder directly.
class MoviePoster extends StatelessWidget {
  const MoviePoster({
    super.key,
    required this.url,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: url.isEmpty
            ? _placeholder(context)
            : CachedNetworkImage(
                imageUrl: url,
                fit: fit,
                placeholder: (ctx, _) => _placeholder(ctx),
                errorWidget: (ctx, _, __) => _placeholder(ctx, error: true),
              ),
      ),
    );
  }

  Widget _placeholder(BuildContext context, {bool error = false}) {
    final colors = context.colors;
    return Container(
      color: colors.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(
        error ? IconsaxPlusLinear.gallery_slash : IconsaxPlusLinear.video,
        color: colors.textMuted,
        size: 32,
      ),
    );
  }
}
