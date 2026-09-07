import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../models/video_model.dart';
import '../../../utils/web_iframe_helper.dart';

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
  bool _isSubscribed = false;
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isSaved = false;

  late int _likeCount;
  String _youtubeViewType = '';
  YoutubePlayerController? _youtubeController;

  final TextEditingController _commentController = TextEditingController();

  final List<CommentItem> _comments = [];

  @override
  void initState() {
    super.initState();
    _likeCount = widget.video.viewsCount > 100 ? (widget.video.viewsCount ~/ 8) : 124;

    final rawUrl = widget.video.url.toLowerCase().trim();
    final isDirectVideo = rawUrl.endsWith('.mp4') ||
        rawUrl.contains('.mp4?') ||
        rawUrl.endsWith('.webm') ||
        rawUrl.contains('.webm?') ||
        rawUrl.endsWith('.mov') ||
        rawUrl.endsWith('.mkv') ||
        rawUrl.contains('/videos/');

    final videoId = _extractVideoId(widget.video.url);

    if (kIsWeb) {
      _youtubeViewType = 'pw-yt-player-${widget.video.id}-${DateTime.now().millisecondsSinceEpoch}';
      final origin = Uri.base.origin;
      final embedUrl = isDirectVideo
          ? widget.video.url
          : 'https://www.youtube.com/embed/$videoId?autoplay=1&mute=1&enablejsapi=1&origin=${Uri.encodeComponent(origin)}&rel=0&modestbranding=1&playsinline=1';
      registerIframe(_youtubeViewType, embedUrl);
    } else {
      if (!isDirectVideo) {
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          autoPlay: true,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            mute: false,
          ),
        );
      }
    }
  }

  String _extractVideoId(String rawUrl) {
    if (rawUrl.isEmpty) return 'kffacxfA7G4';
    final regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/|youtube\.com\/shorts\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(rawUrl);
    if (match != null && match.groupCount >= 1 && match.group(1) != null) {
      return match.group(1)!;
    }
    final trimmed = rawUrl.trim();
    if (trimmed.length == 11 && !trimmed.contains('/') && !trimmed.contains('.')) {
      return trimmed;
    }
    return 'kffacxfA7G4';
  }

  Future<void> _launchExternalVideo() async {
    final videoId = _extractVideoId(widget.video.url);
    final targetUrl = widget.video.url.isNotEmpty && widget.video.url.startsWith('http')
        ? widget.video.url
        : 'https://www.youtube.com/watch?v=$videoId';
    final uri = Uri.parse(targetUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Error launching external video: $e');
    }
  }

  @override
  void dispose() {
    _youtubeController?.close();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open in YouTube / Browser',
            onPressed: _launchExternalVideo,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. IN-APP NATIVE / WEB VIDEO PLAYER CONTAINER
              Container(
                width: double.infinity,
                height: 230,
                color: Colors.black,
                child: kIsWeb && _youtubeViewType.isNotEmpty
                    ? HtmlElementView(viewType: _youtubeViewType)
                    : (_youtubeController != null
                        ? YoutubePlayer(
                            controller: _youtubeController!,
                            aspectRatio: 16 / 9,
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.play_circle_fill, size: 54, color: Colors.white70),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: _launchExternalVideo,
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Open & Play Stream'),
                                ),
                              ],
                            ),
                          )),
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
                    const SizedBox(height: 12),

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
