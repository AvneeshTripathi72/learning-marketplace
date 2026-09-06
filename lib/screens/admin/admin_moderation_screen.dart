import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/video_model.dart';
import '../../providers/ebook_provider.dart';
import '../../providers/video_provider.dart';
import '../publication/ebook/pdf_viewer_screen.dart';
import '../shared/video_player/video_player_screen.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class AdminModerationScreen extends ConsumerStatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  ConsumerState<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends ConsumerState<AdminModerationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(videoSubmissionsProvider.notifier).fetchCloudQueue();
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoSubmissions = ref.watch(videoSubmissionsProvider);
    final pendingVideos = videoSubmissions.where((v) => v.status == VideoStatus.pending).toList();
    final processedVideos = videoSubmissions.where((v) => v.status != VideoStatus.pending).toList();

    final ebookSubmissions = ref.watch(ebookSubmissionsProvider);
    final pendingEbooks = ebookSubmissions.where((item) => item.status == EBookStatus.pending).toList();
    final processedEbooks = ebookSubmissions.where((item) => item.status != EBookStatus.pending).toList();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.verified_user, color: Colors.green, size: 22),
              SizedBox(width: 8),
              Text(
                'Moderation & Approvals',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Sync Cloud Database Queue',
              onPressed: () async {
                await ref.read(videoSubmissionsProvider.notifier).fetchCloudQueue();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔄 Cloud DB Queue synced! Latest submissions loaded.'),
                      backgroundColor: Colors.blue,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.amber,
            indicatorWeight: 3,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.video_library, size: 18),
                    const SizedBox(width: 6),
                    Text('Videos (${pendingVideos.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.menu_book, size: 18),
                    const SizedBox(width: 6),
                    Text('eBooks (${pendingEbooks.length})'),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
        body: TabBarView(
          children: [
            // TAB 1: Video Moderation Queue
            _buildVideoModerationTab(context, pendingVideos, processedVideos, isDark),

            // TAB 2: eBook Moderation Queue
            _buildEBookModerationTab(context, pendingEbooks, processedEbooks, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoModerationTab(
    BuildContext context,
    List<VideoModel> pendingVideos,
    List<VideoModel> processedVideos,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF800020), Color(0xFFC41E3A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.video_call, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Video Submission Queue',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Review video content submitted by Vendors and Public users.',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (pendingVideos.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'No Pending Videos!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'All user & vendor submitted video links have been moderated.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingVideos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final video = pendingVideos[index];
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(video: video),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      video.thumbnailUrl,
                                      width: 100,
                                      height: 65,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 100,
                                        height: 65,
                                        color: Colors.grey.shade800,
                                        child: const Icon(Icons.movie, color: Colors.white70),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      video.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Channel: ${video.channelName} • Submitter: ${video.submittedBy}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'PENDING APPROVAL',
                                        style: TextStyle(
                                          color: Colors.orange.shade800,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // Watch / Preview Video Button
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0000D1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VideoPlayerScreen(video: video),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.play_circle_fill, size: 16),
                                label: const Text('Preview Video', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              Wrap(
                                spacing: 6,
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () {
                                      ref.read(videoSubmissionsProvider.notifier).rejectVideo(video.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Video submission rejected.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.close, size: 14),
                                    label: const Text('Reject', style: TextStyle(fontSize: 11)),
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () {
                                      ref.read(videoSubmissionsProvider.notifier).approveVideo(video.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('"${video.title}" Approved! Published to Video Hub.'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.check, size: 14),
                                    label: const Text('Approve', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          if (processedVideos.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Recently Processed Videos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: processedVideos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final video = processedVideos[index];
                final isApproved = video.status == VideoStatus.approved;
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isApproved ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isApproved ? Icons.check_circle : Icons.cancel,
                        color: isApproved ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          video.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isApproved
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isApproved ? 'APPROVED' : 'REJECTED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isApproved ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEBookModerationTab(
    BuildContext context,
    List<EBookSubmissionModel> pendingEbooks,
    List<EBookSubmissionModel> processedEbooks,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F4C81), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.library_books, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'eBook Verification Queue',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Inspect and verify PDF manuscripts submitted by registered Publishers.',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (pendingEbooks.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'No Pending eBooks!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'All publisher uploaded eBooks are verified & published to students.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingEbooks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = pendingEbooks[index];
                final ebook = item.ebook;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              ebook.coverUrl,
                              width: 65,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 65,
                                height: 90,
                                color: Colors.blueGrey,
                                child: const Icon(Icons.book, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ebook.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Class: ${ebook.classId} • Subject: ${ebook.subjectId}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Submitted By: ${item.submittedBy}',
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 11),
                                ),
                                const SizedBox(height: 6),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PdfViewerScreen(
                                          ebook: ebook,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.picture_as_pdf, size: 14, color: Colors.red),
                                  label: const Text('Inspect PDF Document', style: TextStyle(fontSize: 11)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            onPressed: () {
                              ref.read(ebookSubmissionsProvider.notifier).rejectEBook(ebook.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('eBook rejected.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Reject'),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              ref.read(ebookSubmissionsProvider.notifier).approveEBook(ebook.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('"${ebook.title}" Approved! Published to Students.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Approve eBook'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

          if (processedEbooks.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Recently Processed eBooks',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: processedEbooks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = processedEbooks[index];
                final isApproved = item.status == EBookStatus.approved;
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isApproved ? Colors.blue.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isApproved ? Icons.verified : Icons.cancel,
                        color: isApproved ? Colors.blue : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.ebook.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isApproved
                              ? Colors.blue.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isApproved ? 'VERIFIED' : 'REJECTED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isApproved ? Colors.blue : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
