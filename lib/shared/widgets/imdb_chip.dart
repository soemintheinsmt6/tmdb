import 'package:flutter/material.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tappable "IMDb" pill that deep-links to the title's IMDb page. Used in the
/// movie/TV detail meta row; the owning screen only builds it when an
/// `imdb_id` is present.
class ImdbChip extends StatelessWidget {
  const ImdbChip({super.key, required this.imdbId});

  final String imdbId;

  /// IMDb brand gold.
  static const Color _gold = Color(0xFFF5C518);

  Future<void> _open() async {
    final uri = Uri.parse('https://www.imdb.com/title/$imdbId/');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _gold,
      borderRadius: BorderRadius.circular(6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _open,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            'IMDb',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
