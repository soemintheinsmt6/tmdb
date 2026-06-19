import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/shared/domain/media/media_image.dart';

/// Opens the full-screen image gallery at [initialIndex].
Future<void> openImageGallery(
  BuildContext context, {
  required List<MediaImage> images,
  int initialIndex = 0,
}) {
  return pushView(
    context,
    ImageGalleryViewer(images: images, initialIndex: initialIndex),
  );
}

/// Full-screen, swipeable, pinch-to-zoom backdrop viewer.
class ImageGalleryViewer extends StatefulWidget {
  const ImageGalleryViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  final List<MediaImage> images;
  final int initialIndex;

  @override
  State<ImageGalleryViewer> createState() => _ImageGalleryViewerState();
}

class _ImageGalleryViewerState extends State<ImageGalleryViewer> {
  late final PageController _controller;
  late int _index;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Downloads the current backdrop at full size and saves it to the device's
  /// photo library, requesting permission first.
  Future<void> _saveCurrent() async {
    if (_saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);

    void notify(String message) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    try {
      final image = widget.images[_index];
      // Bounded size (not `original`): full-res backdrops can be several MB.
      final response = await http.get(Uri.parse(image.url(size: 'w1280')));
      if (response.statusCode != 200) throw Exception('download failed');
      // saver_gallery requests photo permission itself and saves via the
      // platform's MediaStore / PHPhotoLibrary.
      final result = await SaverGallery.saveImage(
        response.bodyBytes,
        fileName: image.filePath.replaceAll('/', ''),
        skipIfExists: false,
      );
      notify(result.isSuccess ? 'Saved to Photos' : 'Could not save image');
    } catch (_) {
      notify('Could not save image');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          '${_index + 1} / ${widget.images.length}',
          style: AppTypography.bodyText.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Save to Photos',
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(IconsaxPlusLinear.import_2),
            onPressed: _saving ? null : () => _saveCurrent(),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (_, index) => _GalleryPage(image: widget.images[index]),
      ),
    );
  }
}

/// A single zoomable gallery page. Supports pinch-zoom and double-tap to toggle
/// between fit and 2× (centred on the tapped point), animated.
class _GalleryPage extends StatefulWidget {
  const _GalleryPage({required this.image});

  final MediaImage image;

  @override
  State<_GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<_GalleryPage>
    with SingleTickerProviderStateMixin {
  static const double _doubleTapScale = 2;
  static const _doubleTapTimeout = Duration(milliseconds: 300);

  final _transform = TransformationController();
  late final AnimationController _animController;
  Animation<Matrix4>? _animation;

  // Double-tap is detected from raw pointer events (via [Listener]) rather than
  // a GestureDetector, so it never competes with InteractiveViewer's pinch/pan
  // in the gesture arena. Taps are ignored while a second finger is down.
  int _activePointers = 0;
  Offset _pointerDownPosition = Offset.zero;
  Duration _lastTapStamp = Duration.zero;
  Offset _lastTapPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() => _transform.value = _animation!.value);
  }

  @override
  void dispose() {
    _animController.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    _activePointers++;
    _pointerDownPosition = event.localPosition;
  }

  void _onPointerUp(PointerUpEvent event) {
    final wasSinglePointer = _activePointers == 1;
    if (_activePointers > 0) _activePointers--;
    // Ignore anything that's part of a pinch, or a drag rather than a tap.
    if (!wasSinglePointer) return;
    if ((event.localPosition - _pointerDownPosition).distance > 12) return;

    final now = event.timeStamp;
    final isDoubleTap =
        now - _lastTapStamp < _doubleTapTimeout &&
        (event.localPosition - _lastTapPosition).distance < 48;
    if (isDoubleTap) {
      _lastTapStamp = Duration.zero;
      _handleDoubleTap(event.localPosition);
    } else {
      _lastTapStamp = now;
      _lastTapPosition = event.localPosition;
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_activePointers > 0) _activePointers--;
  }

  void _animateTo(Matrix4 target) {
    _animation = Matrix4Tween(
      begin: _transform.value,
      end: target,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    unawaited(_animController.forward(from: 0));
  }

  void _handleDoubleTap(Offset position) {
    final zoomedIn = _transform.value.getMaxScaleOnAxis() > 1.01;
    if (zoomedIn) {
      _animateTo(Matrix4.identity());
      return;
    }
    // Scale about the tapped point: keeps that point fixed under the zoom.
    final tx = -position.dx * (_doubleTapScale - 1);
    final ty = -position.dy * (_doubleTapScale - 1);
    _animateTo(
      Matrix4(
        _doubleTapScale,
        0,
        0,
        0, //
        0,
        _doubleTapScale,
        0,
        0, //
        0,
        0,
        1,
        0, //
        tx,
        ty,
        0,
        1, //
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: InteractiveViewer(
        transformationController: _transform,
        minScale: 1,
        maxScale: 4,
        child: SizedBox.expand(
          // Fill the page so BoxFit.contain centres the image both axes.
          child: CachedNetworkImage(
            imageUrl: widget.image.url(size: 'w1280'),
            fit: BoxFit.contain,
            placeholder: (_, __) => const Center(
              child: CircularProgressIndicator(color: Colors.white24),
            ),
            errorWidget: (_, __, ___) => const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.white24,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
