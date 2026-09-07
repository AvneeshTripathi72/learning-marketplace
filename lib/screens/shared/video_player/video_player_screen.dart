import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../models/video_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/video_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/web_iframe_helper.dart';

class CommentItem {
  final String id;
  final String userName;
  final String avatarUrl;
  final String commentText;
  final String timeAgo;
  final bool isPinned;
  final bool isTeacher;
  final String? teacherReply;
  int likes;
  bool isLiked;

  CommentItem({
    required this.id,
    required this.userName,
    required this.avatarUrl,
    required this.commentText,
    required this.timeAgo,
    this.isPinned = false,
    this.isTeacher = false,
    this.teacherReply,
    this.likes = 0,
    this.isLiked = false,
  });
}

class ResourceItem {
  final String title;
  final String type;
  final String size;
  final IconData icon;

  const ResourceItem({
    required this.title,
    required this.type,
    required this.size,
    required this.icon,
  });
}

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final VideoModel video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late VideoModel _currentVideo;

  // Player & Controls State
  final bool _isMuted = false;
  String _selectedSpeed = '1.0x';
  String _selectedQuality = '1080p HD';

  // Engagement State
  bool _isSubscribed = false;
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isBookmarked = false;
  bool _isSavedOffline = false;
  late int _likeCount;

  // UI State
  bool _isDescriptionExpanded = false;
  String _youtubeViewType = '';
  YoutubePlayerController? _youtubeController;

  // Controllers
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // Demo Resources Data
  final List<ResourceItem> _resources = const [
    ResourceItem(
      title: 'Class 10 Trigonometry Complete Lecture Notes & Formula Sheet',
      type: 'PDF Document',
      size: '3.4 MB',
      icon: Icons.picture_as_pdf,
    ),
    ResourceItem(
      title: 'Board Exam Important Numerical & Practice Worksheet with Solutions',
      type: 'PDF Document',
      size: '1.8 MB',
      icon: Icons.assignment_outlined,
    ),
    ResourceItem(
      title: 'Instructor Master Slide Deck & Ray Diagrams (High Res)',
      type: 'Presentation',
      size: '5.2 MB',
      icon: Icons.slideshow,
    ),
    ResourceItem(
      title: 'Top 50 Previous Year Questions (PYQs) & Answer Keys',
      type: 'Question Bank',
      size: '2.9 MB',
      icon: Icons.quiz_outlined,
    ),
  ];

  late List<CommentItem> _comments;

  @override
  void initState() {
    super.initState();
    _currentVideo = widget.video;
    _likeCount = _currentVideo.viewsCount > 100 ? (_currentVideo.viewsCount ~/ 7) : 482;
    _initComments();
    _setupPlayer();
  }

  void _initComments() {
    _comments = [
      CommentItem(
        id: 'c1',
        userName: 'Dr. Ananya Sharma (Instructor)',
        avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=100&auto=format&fit=crop',
        commentText: 'Welcome students! Drop your doubts about trigonometric identities below. Homework problem #4 is pinned on slide 18.',
        timeAgo: '2 hours ago',
        isPinned: true,
        isTeacher: true,
        likes: 128,
        isLiked: true,
      ),
      CommentItem(
        id: 'c2',
        userName: 'Rohan Verma',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&auto=format&fit=crop',
        commentText: 'Ma\'am, at 18:30 during step 3 of the proof, why did we multiply both numerator and denominator by (1 - cos θ)?',
        timeAgo: '45 mins ago',
        likes: 24,
        teacherReply: 'Dr. Ananya: Great question Rohan! Multiplying by (1 - cos θ) creates (1 - cos² θ) in the denominator which simplifies directly to sin² θ using the fundamental identity.',
      ),
      CommentItem(
        id: 'c3',
        userName: 'Priya Sundaram',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop',
        commentText: 'This one-shot lecture saved my board preparation! The shortcuts for complementary angles were super helpful.',
        timeAgo: '15 mins ago',
        likes: 19,
      ),
    ];
  }

  void _setupPlayer() {
    final rawUrl = _currentVideo.url.toLowerCase().trim();
    final isDirectVideo = rawUrl.endsWith('.mp4') ||
        rawUrl.contains('.mp4?') ||
        rawUrl.endsWith('.webm') ||
        rawUrl.contains('.webm?') ||
        rawUrl.endsWith('.mov') ||
        rawUrl.endsWith('.mkv') ||
        rawUrl.contains('/videos/');

    final videoId = _extractVideoId(_currentVideo.url);

    if (kIsWeb) {
      _youtubeViewType = 'pw-yt-player-${_currentVideo.id}-${DateTime.now().millisecondsSinceEpoch}';
      final embedUrl = isDirectVideo
          ? _currentVideo.url
          : 'https://www.youtube.com/embed/$videoId?autoplay=1&mute=1&controls=1&enablejsapi=1&rel=0&playsinline=1';
      registerIframe(_youtubeViewType, embedUrl);
    } else {
      if (!isDirectVideo) {
        _youtubeController?.close();
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          autoPlay: true,
          params: YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            mute: _isMuted,
          ),
        );
      }
    }
  }

  void _switchVideo(VideoModel newVideo) {
    setState(() {
      _currentVideo = newVideo;
      _likeCount = newVideo.viewsCount > 100 ? (newVideo.viewsCount ~/ 7) : 310;
      _setupPlayer();
    });
  }

  String _extractVideoId(String rawUrl) {
    if (rawUrl.isEmpty) return 'L_LUpnjgPso';
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
    return 'L_LUpnjgPso';
  }

  Future<void> _launchExternalVideo() async {
    final videoId = _extractVideoId(_currentVideo.url);
    final targetUrl = _currentVideo.url.isNotEmpty && _currentVideo.url.startsWith('http')
        ? _currentVideo.url
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
    _noteController.dispose();
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
          userName: 'You (Verified Student)',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop',
          commentText: text,
          timeAgo: 'Just now',
          likes: 0,
        ),
      );
      _commentController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Question / Comment posted successfully!'),
        backgroundColor: Color(0xFF2FB344),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Bottom Sheets
  void _showQualitySelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final qualities = ['Auto (1080p)', '1080p 60fps HD', '720p HD', '480p SD', '360p Data Saver'];
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Stream Quality', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              ...qualities.map(
                (q) => ListTile(
                  title: Text(q, style: const TextStyle(fontSize: 14)),
                  trailing: _selectedQuality == q ? const Icon(Icons.check_circle, color: Color(0xFF7C9CFF)) : null,
                  onTap: () {
                    setState(() => _selectedQuality = q);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSpeedSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final speeds = ['0.5x', '0.75x', '1.0x (Normal)', '1.25x', '1.5x', '2.0x Fast'];
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Playback Speed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              ...speeds.map(
                (s) => ListTile(
                  title: Text(s, style: const TextStyle(fontSize: 14)),
                  trailing: _selectedSpeed == s ? const Icon(Icons.check_circle, color: Color(0xFF7C9CFF)) : null,
                  onTap: () {
                    setState(() => _selectedSpeed = s);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickNotesDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit_note, color: Color(0xFF7C9CFF)),
                      SizedBox(width: 8),
                      Text('Personal Timestamp Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your study notes at [18:45]...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6CF7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note saved to your student profile notebook!')),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Note'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7);
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final elevatedColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F2F5);
    final textPrimary = isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B);
    final accentPrimary = isDark ? const Color(0xFF7C9CFF) : const Color(0xFF4A6CF7);

    final allVideos = ref.watch(videoSubmissionsProvider);
    final currentUser = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3))),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textPrimary),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentVideo.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          '${_currentVideo.subject} • ${_currentVideo.classId} • ${_currentVideo.publicationName}',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: textPrimary),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.open_in_new, color: accentPrimary),
                    tooltip: 'Launch in External Player',
                    onPressed: _launchExternalVideo,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Main Video & Metadata Column
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildVideoPlayerHero(surfaceColor, accentPrimary),
                          const SizedBox(height: 16),
                          _buildVideoHeaderInfo(textPrimary, textSecondary, accentPrimary),
                          const SizedBox(height: 16),
                          _buildActionButtonsRow(surfaceColor, textPrimary, accentPrimary),
                          const SizedBox(height: 16),
                          _buildInstructorCard(surfaceColor, textPrimary, textSecondary, accentPrimary),
                          const SizedBox(height: 16),
                          _buildDescriptionSection(surfaceColor, elevatedColor, textPrimary, textSecondary),
                          const SizedBox(height: 16),
                          _buildDownloadableResourcesSection(surfaceColor, textPrimary, textSecondary, accentPrimary),
                          const SizedBox(height: 16),
                          _buildCommentsSection(surfaceColor, elevatedColor, textPrimary, textSecondary, accentPrimary),
                        ],
                      ),
                    ),
                  ),
                  // Right Sidebar Playlist & Related Column
                  Container(
                    width: 380,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      border: Border(left: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3))),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPlaylistSection(allVideos, elevatedColor, textPrimary, textSecondary, accentPrimary),
                          const SizedBox(height: 24),
                          _buildRelatedVideosSection(allVideos, elevatedColor, textPrimary, textSecondary),
                          if (currentUser?.role == UserRole.admin) ...[
                            const SizedBox(height: 24),
                            _buildAdminPanel(surfaceColor, textPrimary, textSecondary),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            // Mobile / Tablet Single Column Scroll
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVideoPlayerHero(surfaceColor, accentPrimary),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildVideoHeaderInfo(textPrimary, textSecondary, accentPrimary),
                        const SizedBox(height: 16),
                        _buildActionButtonsRow(surfaceColor, textPrimary, accentPrimary),
                        const SizedBox(height: 16),
                        _buildInstructorCard(surfaceColor, textPrimary, textSecondary, accentPrimary),
                        const SizedBox(height: 16),
                        _buildDescriptionSection(surfaceColor, elevatedColor, textPrimary, textSecondary),
                        const SizedBox(height: 16),
                        _buildDownloadableResourcesSection(surfaceColor, textPrimary, textSecondary, accentPrimary),
                        const SizedBox(height: 16),
                        _buildPlaylistSection(allVideos, elevatedColor, textPrimary, textSecondary, accentPrimary),
                        const SizedBox(height: 20),
                        _buildRelatedVideosSection(allVideos, elevatedColor, textPrimary, textSecondary),
                        const SizedBox(height: 20),
                        _buildCommentsSection(surfaceColor, elevatedColor, textPrimary, textSecondary, accentPrimary),
                        if (currentUser?.role == UserRole.admin) ...[
                          const SizedBox(height: 20),
                          _buildAdminPanel(surfaceColor, textPrimary, textSecondary),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }


  // 1. HERO VIDEO PLAYER CONTAINER WITH CONTROLS OVERLAY
  Widget _buildVideoPlayerHero(Color surfaceColor, Color accentPrimary) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            // Video Frame
            Positioned.fill(
              child: kIsWeb && _youtubeViewType.isNotEmpty
                  ? HtmlElementView(
                      key: ValueKey(_youtubeViewType),
                      viewType: _youtubeViewType,
                    )
                  : (_youtubeController != null
                      ? YoutubePlayer(
                          controller: _youtubeController!,
                          aspectRatio: 16 / 9,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(_currentVideo.thumbnailUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Center(
                            child: CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(Icons.play_arrow, size: 36, color: Colors.white),
                                onPressed: _launchExternalVideo,
                              ),
                            ),
                          ),
                        )),
            ),

            // Top Overlay Bar (Speed, Quality, PIP)
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_tethering, color: Colors.greenAccent, size: 12),
                        const SizedBox(width: 6),
                        Text('LIVE STREAM • $_selectedQuality', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: _showSpeedSelector,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_selectedSpeed, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _showQualitySelector,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.settings, color: Colors.white, size: 13),
                              SizedBox(width: 4),
                              Text('HD', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Player Quick Action Pills (Skip intro, Fullscreen)
            Positioned(
              bottom: 10,
              right: 12,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Skipped 10s ahead')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.forward_10, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Skip Intro', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _launchExternalVideo,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fullscreen, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. VIDEO HEADER METADATA & BADGES
  Widget _buildVideoHeaderInfo(Color textPrimary, Color textSecondary, Color accentPrimary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badges Row
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _buildTagChip(_currentVideo.subject, const Color(0xFF4A6CF7)),
            _buildTagChip(_currentVideo.classId, Colors.orange),
            _buildTagChip(_currentVideo.publicationName, Colors.teal),
            _buildTagChip('PRO COURSE', const Color(0xFFFFB84C), textColor: Colors.black),
            _buildTagChip('Intermediate', Colors.purple),
          ],
        ),
        const SizedBox(height: 10),

        // Title
        Text(
          _currentVideo.title,
          style: TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.3,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        // Views, Likes, Duration & Date Metadata Row
        Row(
          children: [
            Icon(Icons.visibility_outlined, size: 15, color: textSecondary),
            const SizedBox(width: 4),
            Text('${_currentVideo.viewsCount} views', style: TextStyle(fontSize: 12, color: textSecondary)),
            const SizedBox(width: 12),
            Icon(Icons.thumb_up_alt_outlined, size: 15, color: textSecondary),
            const SizedBox(width: 4),
            Text('$_likeCount likes', style: TextStyle(fontSize: 12, color: textSecondary)),
            const SizedBox(width: 12),
            Icon(Icons.timer_outlined, size: 15, color: textSecondary),
            const SizedBox(width: 4),
            Text(_currentVideo.duration, style: TextStyle(fontSize: 12, color: textSecondary)),
            const SizedBox(width: 12),
            Icon(Icons.calendar_today_outlined, size: 13, color: textSecondary),
            const SizedBox(width: 4),
            Text('Updated 2 days ago', style: TextStyle(fontSize: 12, color: textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildTagChip(String label, Color color, {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  // 3. ACTION BUTTONS HORIZONTAL PILL ROW
  Widget _buildActionButtonsRow(Color surfaceColor, Color textPrimary, Color accentPrimary) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Like Button
          _buildActionButton(
            icon: _isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
            label: '$_likeCount',
            isActive: _isLiked,
            activeColor: accentPrimary,
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
          ),
          const SizedBox(width: 8),

          // Dislike Button
          _buildActionButton(
            icon: _isDisliked ? Icons.thumb_down_rounded : Icons.thumb_down_outlined,
            label: 'Dislike',
            isActive: _isDisliked,
            activeColor: Colors.redAccent,
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
          const SizedBox(width: 8),

          // Save / Bookmark
          _buildActionButton(
            icon: _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            label: _isBookmarked ? 'Saved' : 'Bookmark',
            isActive: _isBookmarked,
            activeColor: Colors.amber,
            onPressed: () {
              setState(() => _isBookmarked = !_isBookmarked);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isBookmarked ? 'Added to Saved Bookmarks' : 'Removed from Bookmarks')),
              );
            },
          ),
          const SizedBox(width: 8),

          // Quick Notes Drawer
          _buildActionButton(
            icon: Icons.edit_note_rounded,
            label: 'Notes',
            isActive: false,
            activeColor: accentPrimary,
            onPressed: _showQuickNotesDrawer,
          ),
          const SizedBox(width: 8),

          // Download PDF
          _buildActionButton(
            icon: _isSavedOffline ? Icons.download_done_rounded : Icons.file_download_outlined,
            label: _isSavedOffline ? 'Downloaded' : 'Download Notes',
            isActive: _isSavedOffline,
            activeColor: Colors.green,
            onPressed: () {
              setState(() => _isSavedOffline = !_isSavedOffline);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading lecture PDF package offline...')),
              );
            },
          ),
          const SizedBox(width: 8),

          // Share Button
          _buildActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            isActive: false,
            activeColor: accentPrimary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Course video URL copied to clipboard!')),
              );
            },
          ),
          const SizedBox(width: 8),

          // Save to Playlist
          _buildActionButton(
            icon: Icons.playlist_add_rounded,
            label: 'Playlist',
            isActive: false,
            activeColor: accentPrimary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to study queue playlist')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.15) : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? activeColor : theme.dividerColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? activeColor : theme.textTheme.bodyMedium?.color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? activeColor : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. INSTRUCTOR PROFILE CARD
  Widget _buildInstructorCard(Color surfaceColor, Color textPrimary, Color textSecondary, Color accentPrimary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&auto=format&fit=crop'),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Dr. Ananya Sharma',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Senior Faculty • Oxford Academic Press',
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 13),
                    const SizedBox(width: 3),
                    Text('4.9 (42K reviews)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textPrimary)),
                    const SizedBox(width: 10),
                    Text('1.2M Students', style: TextStyle(fontSize: 11, color: textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSubscribed ? Colors.grey[800] : accentPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () {
              setState(() => _isSubscribed = !_isSubscribed);
            },
            icon: Icon(_isSubscribed ? Icons.check : Icons.notifications_active, size: 15),
            label: Text(_isSubscribed ? 'Following' : 'Follow', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 5. EXPANDABLE DESCRIPTION & SYLLABUS SECTION
  Widget _buildDescriptionSection(Color surfaceColor, Color elevatedColor, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Course Overview & Syllabus', style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Text(
            _currentVideo.description.isNotEmpty
                ? _currentVideo.description
                : 'Comprehensive educational lecture covering foundational concepts, numerical derivations, step-by-step proofs, and essential board exam questions. Designed for Class 10/12 students preparing for competitive and board examinations.',
            maxLines: _isDescriptionExpanded ? null : 3,
            overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, height: 1.45, color: textPrimary),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
            child: Text(
              _isDescriptionExpanded ? 'Show Less ▲' : 'Read Full Description & Outcomes ▼',
              style: const TextStyle(color: Color(0xFF4A6CF7), fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          if (_isDescriptionExpanded) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),
            const Text('🎯 Key Learning Outcomes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            _buildOutcomeItem('Master fundamental trigonometric identities & ratio relationships'),
            _buildOutcomeItem('Solve complex multi-step board exam numerical problems effortlessly'),
            _buildOutcomeItem('Understand geometric proofs and ray diagram principles step-by-step'),
            const SizedBox(height: 14),
            const Text('📌 Lesson Timestamps:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTimestampChip('00:00 Intro & Formulas'),
                _buildTimestampChip('08:15 Key Proofs'),
                _buildTimestampChip('22:40 Board Exam PYQs'),
                _buildTimestampChip('38:10 Homework Problems'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOutcomeItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF2FB344), size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildTimestampChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4A6CF7).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A6CF7).withValues(alpha: 0.3)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4A6CF7))),
    );
  }

  // 6. DOWNLOADABLE RESOURCES SECTION
  Widget _buildDownloadableResourcesSection(Color surfaceColor, Color textPrimary, Color textSecondary, Color accentPrimary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.folder_zip_outlined, color: Color(0xFF4A6CF7)),
                  SizedBox(width: 8),
                  Text('Downloadable Materials', style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A6CF7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${_resources.length} files', style: TextStyle(color: accentPrimary, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _resources.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final res = _resources[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(res.icon, color: accentPrimary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(res.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('${res.type} • ${res.size}', style: TextStyle(fontSize: 11, color: textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Downloading ${res.title}...')),
                        );
                      },
                      icon: const Icon(Icons.download, size: 14),
                      label: const Text('PDF', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 7. COURSE PLAYLIST SECTION
  Widget _buildPlaylistSection(List<VideoModel> allVideos, Color elevatedColor, Color textPrimary, Color textSecondary, Color accentPrimary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Course Syllabus Playlist', style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${allVideos.length} Chapters', style: TextStyle(fontSize: 12, color: textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allVideos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final video = allVideos[index];
              final isCurrent = video.id == _currentVideo.id;
              return InkWell(
                onTap: () => _switchVideo(video),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCurrent ? accentPrimary.withValues(alpha: 0.15) : elevatedColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isCurrent ? accentPrimary : Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      // Thumbnail preview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Image.network(
                              video.thumbnailUrl,
                              width: 80,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(width: 80, height: 48, color: Colors.grey),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                color: Colors.black.withValues(alpha: 0.8),
                                child: Text(video.duration, style: const TextStyle(color: Colors.white, fontSize: 9)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (isCurrent) ...[
                                  const Icon(Icons.graphic_eq, color: Color(0xFF4A6CF7), size: 14),
                                  const SizedBox(width: 4),
                                ],
                                Expanded(
                                  child: Text(
                                    video.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                      color: isCurrent ? accentPrimary : textPrimary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text('${video.channelName} • Chapter ${index + 1}', style: TextStyle(fontSize: 10, color: textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.play_circle_outline, size: 20, color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 8. RELATED VIDEOS HORIZONTAL CAROUSEL
  Widget _buildRelatedVideosSection(List<VideoModel> allVideos, Color elevatedColor, Color textPrimary, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recommended Lectures', style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: allVideos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final video = allVideos[index];
              return InkWell(
                onTap: () => _switchVideo(video),
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Image.network(
                            video.thumbnailUrl,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(height: 100, color: Colors.grey),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              color: Colors.black.withValues(alpha: 0.8),
                              child: Text(video.duration, style: const TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, height: 1.2),
                            ),
                            const SizedBox(height: 4),
                            Text('${video.viewsCount} views • ${video.subject}', style: TextStyle(fontSize: 10, color: textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 9. COMMENTS & DISCUSSION SECTION
  Widget _buildCommentsSection(Color surfaceColor, Color elevatedColor, Color textPrimary, Color textSecondary, Color accentPrimary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Student Doubts & Discussion', style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${_comments.length}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Comment Input Box
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Ask your instructor a doubt or post a comment...',
                    hintStyle: TextStyle(fontSize: 12, color: textSecondary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.send_rounded, color: accentPrimary),
                onPressed: _addComment,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Comment List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _comments[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.isPinned ? accentPrimary.withValues(alpha: 0.08) : elevatedColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: item.isPinned ? accentPrimary.withValues(alpha: 0.4) : Colors.transparent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.isPinned) ...[
                      const Row(
                        children: [
                          Icon(Icons.push_pin, size: 12, color: Color(0xFF4A6CF7)),
                          SizedBox(width: 4),
                          Text('Pinned by Instructor', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4A6CF7))),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(item.avatarUrl),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(item.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  if (item.isTeacher) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, color: Colors.blue, size: 14),
                                  ],
                                  const Spacer(),
                                  Text(item.timeAgo, style: TextStyle(fontSize: 11, color: textSecondary)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(item.commentText, style: TextStyle(fontSize: 13, height: 1.35, color: textPrimary)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (item.isLiked) {
                                          item.isLiked = false;
                                          item.likes--;
                                        } else {
                                          item.isLiked = true;
                                          item.likes++;
                                        }
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          item.isLiked ? Icons.favorite : Icons.favorite_border,
                                          size: 14,
                                          color: item.isLiked ? Colors.red : textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text('${item.likes}', style: TextStyle(fontSize: 11, color: textSecondary)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text('Reply', style: TextStyle(fontSize: 11, color: accentPrimary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (item.teacherReply != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A6CF7).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(item.teacherReply!, style: const TextStyle(fontSize: 12, height: 1.35, fontStyle: FontStyle.italic)),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 10. ADMIN PANEL CONTROLS
  Widget _buildAdminPanel(Color surfaceColor, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.amber),
              SizedBox(width: 8),
              Text('Instructor & Admin Controls', style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 14),
                label: const Text('Edit Details'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.analytics_outlined, size: 14),
                label: const Text('Analytics'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                onPressed: () {},
                icon: const Icon(Icons.delete_outline, size: 14),
                label: const Text('Delete Stream'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

