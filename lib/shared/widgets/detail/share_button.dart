import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tmdb/core/sharing/media_share.dart';
import 'package:tmdb/shared/domain/media/shareable_media.dart';

/// Share-sheet icon button for a [media] title. Works for movies and TV shows.
class ShareButton extends StatelessWidget {
  const ShareButton({super.key, required this.media, this.color});

  final ShareableMedia media;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Share',
      icon: Icon(CupertinoIcons.share, color: color),
      onPressed: () => shareMedia(media),
    );
  }
}
