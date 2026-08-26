import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/video_playback_resolver_service.dart';
import 'animated_card.dart';

class VideoCard extends StatefulWidget {
  final VideoModel video;
  final VoidCallback onTap;
  final double? width;

  const VideoCard({
    super.key,
    required this.video,
    required this.onTap,
    this.width = 260.0,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool _isLiked = false;
  bool _isSaved = false;

  IconData _getPlatformIcon() {
    switch (widget.video.platform) {
      case VideoPlatform.youtube:
        return Icons.play_circle_fill;
      case VideoPlatform.instagram:
        return Icons.camera_alt;
      case VideoPlatform.facebook:
        return Icons.facebook;
    }
  }

  Color _getPlatformColor() {
    switch (widget.video.platform) {
      case VideoPlatform.youtube:
        return Colors.red;
      case VideoPlatform.instagram:
        return Colors.purple;
      case VideoPlatform.facebook:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: AnimatedCard(
        onTap: () => VideoPlaybackResolverService.playVideo(widget.video),
        child: Card(
          margin: const EdgeInsets.only(right: 12, bottom: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(_getPlatformIcon(), color: _getPlatformColor()),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.video.channelName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Category: ${widget.video.category}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        color: _isLiked ? Colors.blue : null,
                      ),
                      onPressed: () => setState(() => _isLiked = !_isLiked),
                    ),
                    IconButton(
                      icon: Icon(
                        _isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: _isSaved ? Colors.amber : null,
                      ),
                      onPressed: () => setState(() => _isSaved = !_isSaved),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sharing video link...')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
