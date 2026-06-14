import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isFullScreen = false;
  bool _playerReady = false;

  /// Whether the playback controls (scrubber + buttons) are currently shown.
  /// Hidden on launch; a tap reveals them. They auto-hide after
  /// [_controlsHideDelay] while playing, and stay up while paused.
  bool _controlsVisible = false;

  /// Last observed player state, so [_onControllerUpdate] reacts only to real
  /// play/pause transitions (and ignores buffering/cued churn).
  PlayerState? _lastPlayerState;

  Timer? _controlsHideTimer;
  static const Duration _controlsHideDelay = Duration(seconds: 3);

  /// The video's real width/height ratio, so vertical "short"-style teasers
  /// fill the player instead of being pillar-boxed inside a 16:9 box. Null
  /// until measured from the thumbnail; [_aspectRatio] falls back to 16:9.
  double? _videoAspectRatio;
  double get _aspectRatio => _videoAspectRatio ?? 16 / 9;

  /// Whether [_detectAspectRatio] has finished. The player is built only once
  /// this is true, because [YoutubePlayer] reads its `aspectRatio` once in its
  /// own initState and never picks up later changes — so the ratio must be
  /// known *before* the player is first created, or the box stays 16:9.
  bool _aspectResolved = false;
  bool get _isVertical => _aspectRatio < 1;

  /// Preserves the player's state (and the underlying webview, so playback
  /// doesn't restart) when it is reparented between the portrait and fullscreen
  /// layouts.
  final GlobalKey _playerKey = GlobalKey();

  /// While the user is dragging the scrubber, holds the pending position (in
  /// seconds) so the thumb tracks the finger instead of the live playhead.
  double? _dragSeconds;

  /// Seconds a double-tap last seeked by (±10), shown briefly as an overlay;
  /// `0` hides it. [_seekFeedbackTimer] clears it after a moment.
  int _seekFeedback = 0;
  Timer? _seekFeedbackTimer;

  /// X of the last double-tap, used to pick the seek direction (left/right).
  double _lastDoubleTapDx = 0;

  static const int _seekStep = 10;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.key,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        // Hide the package's overlay (its always-on centre play/pause button);
        // we draw a slim tap-to-toggle layer + red progress bar instead.
        hideControls: true,
        // Don't flash YouTube's thumbnail while loading — we show a spinner
        // until the player is ready (better on slow connections / first load).
        hideThumbnail: true,
      ),
    );
    _controller.addListener(_onControllerUpdate);
    unawaited(_detectAspectRatio());
    // Stay portrait until the user opts into fullscreen, so rotating the device
    // doesn't render the portrait layout sideways.
    unawaited(
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
      ]),
    );
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    final value = _controller.value;
    if (value.hasError && !_embedFailed) {
      setState(() => _embedFailed = true);
    }
    if (!_playerReady && value.isReady) {
      setState(() => _playerReady = true);
    }
    final state = value.playerState;
    if (state != _lastPlayerState) {
      _lastPlayerState = state;
      if (state == PlayerState.playing) {
        // Resumed: let the controls fade out shortly.
        _scheduleControlsHide();
      } else if (state == PlayerState.paused) {
        // Paused: surface the controls and keep them up.
        _controlsHideTimer?.cancel();
        if (!_controlsVisible) setState(() => _controlsVisible = true);
      }
    }
  }

  /// Measures the video's true aspect ratio so vertical "short"-style teasers
  /// render upright and full-size instead of pillar-boxed inside a 16:9 frame.
  ///
  /// Reads YouTube's `oardefault.jpg` ("original aspect ratio") thumbnail: it
  /// exists only for non-16:9 videos and reports their real dimensions (a
  /// vertical teaser is e.g. 1080×1920). For ordinary landscape videos it 404s
  /// — the catch below then keeps the 16:9 default. (The `maxresdefault.jpg` is
  /// no use here: it's always a 16:9 canvas with the video letterboxed inside.)
  Future<void> _detectAspectRatio() async {
    final provider = NetworkImage(
      'https://i.ytimg.com/vi/${widget.video.key}/oardefault.jpg',
    );
    final stream = provider.resolve(ImageConfiguration.empty);
    final completer = Completer<Size>();
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!completer.isCompleted) {
          completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble()),
          );
        }
        stream.removeListener(listener);
      },
      onError: (error, _) {
        if (!completer.isCompleted) completer.completeError(error);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);

    try {
      final size = await completer.future.timeout(const Duration(seconds: 3));
      if (size.height != 0) {
        _videoAspectRatio = (size.width / size.height)
            .clamp(0.4, 2.0)
            .toDouble();
      }
    } catch (_) {
      // No `oardefault` thumbnail (404), or it timed out — the video is
      // standard 16:9, so the default is already correct.
    } finally {
      // Unblock the player build either way (with the measured ratio or 16:9).
      if (mounted) setState(() => _aspectResolved = true);
    }
  }

  @override
  void dispose() {
    _seekFeedbackTimer?.cancel();
    _controlsHideTimer?.cancel();
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    // Leave the app as we found it: bars back, orientation unlocked.
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    unawaited(SystemChrome.setPreferredOrientations(DeviceOrientation.values));
    super.dispose();
  }

  /// A tap on the video either reveals the controls (when hidden) or toggles
  /// play/pause (when they're already showing) — so the first tap never
  /// pauses, and the next tap within the visible window does.
  void _handleTap() {
    if (_controlsVisible) {
      _togglePlayPause();
    } else {
      _showControls();
    }
  }

  void _togglePlayPause() {
    _controlsHideTimer?.cancel();
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  /// Reveals the controls and arms the auto-hide timer.
  void _showControls() {
    if (!_controlsVisible) setState(() => _controlsVisible = true);
    _scheduleControlsHide();
  }

  /// Schedules the controls to fade out after [_controlsHideDelay] — but only
  /// while playing; paused leaves them up.
  void _scheduleControlsHide() {
    _controlsHideTimer?.cancel();
    if (!_controller.value.isPlaying) return;
    _controlsHideTimer = Timer(_controlsHideDelay, () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  /// Wraps a control widget so it fades with [_controlsVisible] and stops
  /// intercepting taps while hidden — letting a tap reach the gesture layer and
  /// reveal the controls instead of being swallowed.
  Widget _animatedControls(Widget child) {
    return IgnorePointer(
      ignoring: !_controlsVisible,
      child: AnimatedOpacity(
        opacity: _controlsVisible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: child,
      ),
    );
  }

  /// Seeks by [seconds] (negative = back), clamped to the video bounds, and
  /// flashes the seek indicator.
  void _seekBy(int seconds) {
    final value = _controller.value;
    final duration = value.metaData.duration;
    var target = value.position + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (duration > Duration.zero && target > duration) target = duration;
    _controller.seekTo(target);

    setState(() => _seekFeedback = seconds);
    _seekFeedbackTimer?.cancel();
    _seekFeedbackTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _seekFeedback = 0);
    });
  }

  /// Full-bleed gesture layer over the video: single tap toggles play/pause,
  /// double tap on the left/right half seeks back/forward by [_seekStep].
  Widget _gestureLayer() {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleTap,
            onDoubleTapDown: (details) =>
                _lastDoubleTapDx = details.localPosition.dx,
            onDoubleTap: () => _seekBy(
              _lastDoubleTapDx < constraints.maxWidth / 2
                  ? -_seekStep
                  : _seekStep,
            ),
          );
        },
      ),
    );
  }

  /// Black cover with a spinner shown until the player is ready, so a slow or
  /// first load shows a loading indicator instead of YouTube's thumbnail.
  Widget _loadingOverlay() {
    if (_playerReady) return const SizedBox.shrink();
    return const Positioned.fill(
      child: ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }

  /// Brief "10s" overlay on the side that was double-tapped.
  Widget _seekFeedbackOverlay() {
    if (_seekFeedback == 0) return const SizedBox.shrink();
    final forward = _seekFeedback > 0;
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: forward ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  forward
                      ? Icons.fast_forward_rounded
                      : Icons.fast_rewind_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _enterFullScreen() {
    setState(() => _isFullScreen = true);
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
    // Vertical videos go immersive but stay upright — rotating them to
    // landscape would only shrink them again behind huge side bars.
    unawaited(
      SystemChrome.setPreferredOrientations(
        _isVertical
            ? const [DeviceOrientation.portraitUp]
            : const [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ],
      ),
    );
  }

  void _exitFullScreen() {
    setState(() => _isFullScreen = false);
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    unawaited(
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
      ]),
    );
  }

  void _toggleFullScreen() {
    if (_isFullScreen) {
      _exitFullScreen();
    } else {
      _enterFullScreen();
    }
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

  static String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0
        ? '${d.inHours}:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  /// Custom bottom control bar — current time, a draggable red scrubber, total
  /// time, and a fullscreen toggle. Replaces the package overlay so there's no
  /// centre play/pause button; playback is toggled by tapping the video.
  Widget _controlsBar() {
    return ValueListenableBuilder<YoutubePlayerValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        final total = value.metaData.duration;
        final totalSeconds = total.inSeconds.toDouble();
        final liveSeconds = value.position.inSeconds.toDouble();
        final current = _dragSeconds ?? liveSeconds;
        final maxSeconds = totalSeconds > 0 ? totalSeconds : 1.0;
        final shownPosition = Duration(seconds: current.round());

        const textStyle = TextStyle(color: Colors.white, fontSize: 12);
        return Container(
          padding: const EdgeInsets.only(
            left: 12,
            right: 4,
            top: 24,
            bottom: 4,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black54],
            ),
          ),
          child: Row(
            children: [
              Text(_formatDuration(shownPosition), style: textStyle),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _youTubeRed,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: _youTubeRed,
                    trackHeight: 2.5,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: current.clamp(0.0, maxSeconds),
                    max: maxSeconds,
                    onChangeStart: (v) {
                      _controlsHideTimer?.cancel();
                      setState(() => _dragSeconds = v);
                    },
                    onChanged: (v) => setState(() => _dragSeconds = v),
                    onChangeEnd: (v) {
                      _controller.seekTo(Duration(seconds: v.round()));
                      setState(() => _dragSeconds = null);
                      _scheduleControlsHide();
                    },
                  ),
                ),
              ),
              Text(_formatDuration(total), style: textStyle),
              IconButton(
                tooltip: _isFullScreen ? 'Exit fullscreen' : 'Fullscreen',
                color: Colors.white,
                icon: Icon(
                  _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                ),
                onPressed: _toggleFullScreen,
              ),
            ],
          ),
        );
      },
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
    // Keep the player alive across the portrait↔fullscreen reparent so toggling
    // never reloads the video. The key goes on a wrapper, not on YoutubePlayer
    // itself — the package forwards a widget key to its inner webview, so a
    // GlobalKey on YoutubePlayer would land on two widgets at once.
    //
    // Build the player only once the aspect ratio is known: YoutubePlayer locks
    // in its `aspectRatio` at construction (see [_aspectResolved]), so a 16:9
    // placeholder is shown (under the black loading overlay) until then.
    final player = _aspectResolved
        ? KeyedSubtree(
            key: _playerKey,
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: _aspectRatio,
            ),
          )
        : const AspectRatio(
            aspectRatio: 16 / 9,
            child: ColoredBox(color: Colors.black),
          );

    final body = _isFullScreen
        ? Stack(
            fit: StackFit.expand,
            children: [
              Center(child: player),
              _seekFeedbackOverlay(),
              // Gesture layer on top so taps/double-taps don't reach the embed.
              _gestureLayer(),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _animatedControls(
                  SafeArea(top: false, child: _controlsBar()),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: _animatedControls(_exitFullScreenButton()),
                ),
              ),
              _loadingOverlay(),
            ],
          )
        : Center(
            child: Stack(
              children: [
                player,
                _seekFeedbackOverlay(),
                _gestureLayer(),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _animatedControls(_controlsBar()),
                ),
                _loadingOverlay(),
              ],
            ),
          );

    return PopScope(
      // While fullscreen, a back gesture returns to portrait instead of leaving.
      canPop: !_isFullScreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isFullScreen) _exitFullScreen();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _isFullScreen ? null : _appBar(),
        body: body,
      ),
    );
  }

  /// Top-left "back to portrait" affordance shown only in fullscreen.
  Widget _exitFullScreenButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: Colors.black45,
        child: IconButton(
          tooltip: 'Back to portrait',
          icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
          onPressed: _exitFullScreen,
        ),
      ),
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
