import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../../../models/video_model.dart';

class CommentItem {
  final String id;
  final String userName;
  final String avatarUrl;
  final String commentText;
  final String timeAgo;
  int likes;
  bool isLiked;

  CommentItem({
    required this.id,
    required this.userName,
    required this.avatarUrl,
    required this.commentText,
    required this.timeAgo,
    this.likes = 0,
    this.isLiked = false,
  });
}

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isPlaying = true;
  bool _isSubscribed = false;
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isSaved = false;

  late int _likeCount;
  String _youtubeViewType = '';
  double _playbackPosition = 0.35; // 35% watched
  String _selectedSpeed = '1.0x';

  final TextEditingController _commentController = TextEditingController();

  final List<CommentItem> _comments = [
    CommentItem(
      id: 'c1',
      userName: 'Aman Verma (Student)',
      avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100',
      commentText: 'Sir Trigonometry exercise 8.4 question 5 proof step 3 clear ho gaya! Thank you so much 🔥',
      timeAgo: '10 mins ago',
      likes: 14,
    ),
    CommentItem(
      id: 'c2',
      userName: 'Priya Sharma (Class 10)',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      commentText: 'Best explanation lecture for board exam 2026! Very clear concepts.',
      timeAgo: '45 mins ago',
      likes: 28,
    ),
    CommentItem(
      id: 'c3',
      userName: 'Rohan Mehta',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      commentText: 'Please upload Chapter 9 Applications of Trigonometry Part 2 as well sir! 🙏',
      timeAgo: '2 hours ago',
      likes: 9,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _likeCount = widget.video.viewsCount > 100 ? (widget.video.viewsCount ~/ 8) : 124;

    if (kIsWeb) {
      _youtubeViewType = 'pw-yt-player-${widget.video.id}-${DateTime.now().millisecondsSinceEpoch}';
      final embedUrl = _extractEmbedUrl(widget.video.url);
      ui_web.platformViewRegistry.registerViewFactory(
        _youtubeViewType,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = embedUrl
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
            ..allowFullscreen = true;
          return iframe;
        },
      );
    }
  }

  String _extractEmbedUrl(String rawUrl) {
    String videoId = 'kffacxfA7G4'; // Trigonometry Class 10 Lecture ID
    if (rawUrl.contains('v=')) {
      final parts = rawUrl.split('v=');
      if (parts.length > 1) {
        videoId = parts[1].split('&').first;
      }
    } else if (rawUrl.contains('youtu.be/')) {
      final parts = rawUrl.split('youtu.be/');
      if (parts.length > 1) {
        videoId = parts[1].split('?').first;
      }
    } else if (rawUrl.contains('embed/')) {
      final parts = rawUrl.split('embed/');
      if (parts.length > 1) {
        videoId = parts[1].split('?').first;
      }
    }
    return 'https://www.youtube.com/embed/$videoId?autoplay=1&rel=0&modestbranding=1';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.insert(
        0,
        CommentItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userName: 'You (Student)',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
          commentText: text,
          timeAgo: 'Just now',
          likes: 0,
        ),
      );
      _commentController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment posted successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fallbackThumbnail = widget.video.thumbnailUrl.isNotEmpty && widget.video.thumbnailUrl.startsWith('http')
        ? widget.video.thumbnailUrl
        : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&auto=format&fit=crop';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(
          widget.video.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. IN-APP PW-STYLE EMBEDDED VIDEO PLAYER CONTAINER
              Container(
                width: double.infinity,
                height: 230,
                color: Colors.black,
                child: kIsWeb && _youtubeViewType.isNotEmpty
                    ? HtmlElementView(viewType: _youtubeViewType)
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          // Video Thumbnail Background
                          Image.network(
                            fallbackThumbnail,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.black),
                          ),

                          // Dark Semi-transparent Video Overlay
                          Container(
                            color: Colors.black.withValues(alpha: _isPlaying ? 0.35 : 0.65),
                          ),

                          // Center Play / Pause Icon Button
                          GestureDetector(
                            onTap: () => setState(() => _isPlaying = !_isPlaying),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                    blurRadius: 16,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                size: 44,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Top Player Bar Badges (Live Badge & Speed Selector)
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.circle, color: Colors.white, size: 8),
                                      SizedBox(width: 6),
                                      Text(
                                        'IN-APP PLAYER',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  initialValue: _selectedSpeed,
                                  onSelected: (speed) => setState(() => _selectedSpeed = speed),
                                  itemBuilder: (context) => ['0.75x', '1.0x', '1.25x', '1.5x', '2.0x']
                                      .map((s) => PopupMenuItem(value: s, child: Text('Speed $s')))
                                      .toList(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.speed, color: Colors.white, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          _selectedSpeed,
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bottom Seeker Controls & Duration Timeline
                          Positioned(
                            bottom: 8,
                            left: 12,
                            right: 12,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 3,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                    activeTrackColor: theme.colorScheme.primary,
                                    inactiveTrackColor: Colors.white30,
                                    thumbColor: Colors.white,
                                  ),
                                  child: Slider(
                                    value: _playbackPosition,
                                    onChanged: (val) => setState(() => _playbackPosition = val),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '14:20 / ${widget.video.duration}',
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                      const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 20),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),

              // 2. VIDEO TITLE & METADATA SECTION
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.video.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.video.viewsCount} views • Streamed live in ${widget.video.category}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. CHANNEL & SUBSCRIBE ROW
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: theme.colorScheme.primary,
                            child: const Icon(Icons.school, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        widget.video.channelName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, color: Colors.blue, size: 15),
                                  ],
                                ),
                                const Text(
                                  'Verified Publisher • 1.2M Subs',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton.icon(
                            onPressed: () => setState(() => _isSubscribed = !_isSubscribed),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isSubscribed ? Colors.grey[800] : theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            icon: Icon(_isSubscribed ? Icons.check : Icons.notifications_active, size: 14),
                            label: Text(_isSubscribed ? 'Subscribed' : 'Subscribe', style: const TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. ACTION BUTTONS ROW (Like, Dislike, Share, Save)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Like Button
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _isLiked ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
                            side: BorderSide(color: _isLiked ? theme.colorScheme.primary : theme.dividerColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () {
                            setState(() {
                              if (_isLiked) {
                                _isLiked = false;
                                _likeCount--;
                              } else {
                                _isLiked = true;
                                _likeCount++;
                                _isDisliked = false;
                              }
                            });
                          },
                          icon: Icon(
                            _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            size: 18,
                            color: _isLiked ? theme.colorScheme.primary : null,
                          ),
                          label: Text('$_likeCount', style: const TextStyle(fontSize: 13)),
                        ),

                        // Dislike Button
                        IconButton(
                          icon: Icon(_isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined),
                          color: _isDisliked ? Colors.redAccent : null,
                          onPressed: () {
                            setState(() {
                              _isDisliked = !_isDisliked;
                              if (_isDisliked && _isLiked) {
                                _isLiked = false;
                                _likeCount--;
                              }
                            });
                          },
                        ),

                        // Share Button
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Video link copied to clipboard!')),
                            );
                          },
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text('Share'),
                        ),

                        // Download / Save Button
                        IconButton(
                          icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
                          color: _isSaved ? Colors.amber : null,
                          onPressed: () => setState(() => _isSaved = !_isSaved),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // 5. INTERACTIVE PW COMMENTS & DOUBTS SECTION
                    Row(
                      children: [
                        const Text(
                          'Comments & Doubts',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_comments.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Add Comment Input Container
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.person, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Ask a doubt or write a comment...',
                              hintStyle: const TextStyle(fontSize: 13),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send_rounded),
                          color: theme.colorScheme.primary,
                          onPressed: _addComment,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // List of Comments
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(comment.avatarUrl),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          comment.userName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        Text(
                                          comment.timeAgo,
                                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment.commentText,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.3,
                                        color: theme.textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (comment.isLiked) {
                                            comment.isLiked = false;
                                            comment.likes--;
                                          } else {
                                            comment.isLiked = true;
                                            comment.likes++;
                                          }
                                        });
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            comment.isLiked ? Icons.favorite : Icons.favorite_border,
                                            size: 14,
                                            color: comment.isLiked ? Colors.red : Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${comment.likes}',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
