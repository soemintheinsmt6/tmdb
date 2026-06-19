import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/shared/domain/watch_provider.dart';
import 'package:tmdb/shared/domain/watch_providers.dart';
import 'package:url_launcher/url_launcher.dart';

/// "Where to Watch" block for the movie/TV detail screens: stream / rent / buy
/// provider logos for the device region. Renders nothing when [providers] is
/// null or empty. Data is sourced from JustWatch (attribution shown); tapping a
/// logo opens the full TMDB watch page.
class WatchProvidersSection extends StatelessWidget {
  const WatchProvidersSection({
    super.key,
    required this.providers,
    this.horizontalPadding = 16,
  });

  final WatchProviders? providers;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final p = providers;
    if (p == null || p.isEmpty) return const SizedBox.shrink();

    Future<void> openLink() async {
      if (p.link.isEmpty) return;
      await launchUrl(Uri.parse(p.link), mode: LaunchMode.externalApplication);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Where to Watch', style: AppTypography.subTitle),
              const SizedBox(width: 8),
              _RegionBadge(region: p.region),
              const Spacer(),
              if (p.link.isNotEmpty) _JustWatchLink(onTap: openLink),
            ],
          ),
          const SizedBox(height: 12),
          if (p.stream.isNotEmpty)
            _ProviderRow(label: 'Stream', providers: p.stream, onTap: openLink),
          if (p.rent.isNotEmpty)
            _ProviderRow(label: 'Rent', providers: p.rent, onTap: openLink),
          if (p.buy.isNotEmpty)
            _ProviderRow(label: 'Buy', providers: p.buy, onTap: openLink),
        ],
      ),
    );
  }
}

class _ProviderRow extends StatelessWidget {
  const _ProviderRow({
    required this.label,
    required this.providers,
    required this.onTap,
  });

  final String label;
  final List<WatchProvider> providers;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Text(
                label,
                style: AppTypography.smallText.copyWith(
                  color: colors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final provider in providers)
                  _ProviderLogo(provider: provider, onTap: onTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderLogo extends StatelessWidget {
  const _ProviderLogo({required this.provider, required this.onTap});

  final WatchProvider provider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = provider.logoUrl();
    Widget fallback() => Container(
      color: colors.surfaceMuted,
      alignment: Alignment.center,
      child: Text(
        provider.name.isEmpty ? '?' : provider.name.characters.first,
        style: AppTypography.bodyText.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return Tooltip(
      message: provider.name,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 46,
            height: 46,
            child: url.isEmpty
                ? fallback()
                : CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: colors.surfaceMuted),
                    errorWidget: (_, __, ___) => fallback(),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Small pill showing the ISO region the offerings apply to (e.g. `US`).
class _RegionBadge extends StatelessWidget {
  const _RegionBadge({required this.region});

  final String region;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        region,
        style: AppTypography.labelSmall.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// JustWatch attribution required by TMDB when using watch-provider data.
class _JustWatchLink extends StatelessWidget {
  const _JustWatchLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.cyan,
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      icon: const Icon(IconsaxPlusLinear.export_3, size: 14),
      label: const Text('JustWatch', style: AppTypography.smallText),
    );
  }
}
