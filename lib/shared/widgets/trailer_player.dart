import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/shared/domain/video.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// YouTube brand red, used for the progress bar and the play-badge mark.
const Color _youTubeRed = Color(0xFFFF0000);

/// Pushes a full-screen [TrailerPlayerScreen] for [video]. Shared by the movie
/// and TV detail screens.
Future<void> playTrailer(BuildContext context, Video video) {
  return pushView(context, TrailerPlayerScreen(video: video));
}

/// Plays a single YouTube [Video] using [youtube_player_flutter], whose native
/// webview embed succeeds for far more videos on mobile than the IFrame API.
///
/// A few videos still refuse embedding entirely (owner-disabled, age- or
/// region-restricted). When the player reports an error we fall back to a
/// "Watch on YouTube" action, and that action is also always available in the
/// app bar as an escape hatch.
class TrailerPlayerScreen extends StatefulWidget {
  const TrailerPlayerScreen({super.key, required this.video});

  final Video video;

  @override
  State<TrailerPlayerScreen> createState() => _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<TrailerPlayerScreen> {
  late final YoutubePlayerController _controller;
  bool _embedFailed = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.key,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (_controller.value.hasError && !_embedFailed && mounted) {
      setState(() => _embedFailed = true);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openOnYouTube() async {
    final url = widget.video.youtubeUrl;
    if (url.isEmpty) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Text(
        widget.video.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        // Always-available escape hatch for videos that refuse in-app embedding.
        IconButton(
          tooltip: 'Watch on YouTube',
          icon: const _YouTubeIcon(),
          onPressed: () => unawaited(_openOnYouTube()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_embedFailed) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: _appBar(),
        body: _EmbedUnavailable(onWatch: () => unawaited(_openOnYouTube())),
      );
    }
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        aspectRatio: 16 / 9,
        showVideoProgressIndicator: true,
        progressIndicatorColor: _youTubeRed,
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: _appBar(),
          body: Center(child: player),
        );
      },
    );
  }
}

/// Fallback shown when a video can't be embedded — offers to open it externally.
class _EmbedUnavailable extends StatelessWidget {
  const _EmbedUnavailable({required this.onWatch});

  final VoidCallback onWatch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              IconsaxPlusLinear.video_slash,
              color: Colors.white70,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              "This trailer can't be played in the app.",
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'The owner has disabled embedded playback for this video.',
              textAlign: TextAlign.center,
              style: AppTypography.smallText.copyWith(color: Colors.white60),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onWatch,
              icon: const _YouTubeIcon(),
              label: const Text('Watch on YouTube'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The YouTube play-badge mark — a red rounded rectangle with a white play
/// triangle. Avoids pulling in a brand-icon font for a single glyph.
class _YouTubeIcon extends StatelessWidget {
  const _YouTubeIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 18,
      decoration: BoxDecoration(
        color: _youTubeRed,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: 15,
      ),
    );
  }
}
