import 'package:flutter/material.dart';
import '../../../models/video_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isSubscribed = false;
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  widget.video.thumbnailUrl.startsWith('http')
                      ? Image.network(
                          widget.video.thumbnailUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.play_circle_fill,
                            size: 64,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.play_circle_fill,
                          size: 64,
                          color: Colors.white,
                        ),
                  const Icon(
                    Icons.play_circle_fill,
                    size: 64,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.video.viewsCount} views • ${widget.video.category}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const CircleAvatar(
                        child: Icon(Icons.school),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.video.channelName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Verified Publication Channel',
                              style: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() => _isSubscribed = !_isSubscribed),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSubscribed ? Colors.grey[800] : theme.colorScheme.primary,
                        ),
                        child: Text(_isSubscribed ? 'Subscribed' : 'Subscribe'),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(_isLiked ? Icons.thumb_up : Icons.thumb_up_outlined),
                        onPressed: () => setState(() => _isLiked = !_isLiked),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark_border),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
