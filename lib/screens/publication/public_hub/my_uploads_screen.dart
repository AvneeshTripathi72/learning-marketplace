import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_model.dart';
import '../../../models/video_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/video_provider.dart';
import '../../../widgets/video_card.dart';
import '../../shared/video_player/video_player_screen.dart';

class MyUploadsScreen extends ConsumerWidget {
  const MyUploadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isAdmin = user?.role == UserRole.admin;
    final submissions = ref.watch(videoSubmissionsProvider);

    final activeVideos = submissions.where((v) => v.status == VideoStatus.approved).toList();
    final pendingVideos = submissions.where((v) => v.status == VideoStatus.pending || v.status == VideoStatus.rejected).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAdmin ? 'All Video Submissions (Admin View)' : 'My Uploaded Videos'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Active Videos (${activeVideos.length})'),
              Tab(text: 'Pending / Inactive (${pendingVideos.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildVideoList(ref, context, activeVideos, 'No active approved videos.', isPendingTab: false, isAdmin: isAdmin),
            _buildVideoList(ref, context, pendingVideos, 'No pending submissions in queue.', isPendingTab: true, isAdmin: isAdmin),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoList(
    WidgetRef ref,
    BuildContext context,
    List<VideoModel> videos,
    String emptyMessage, {
    required bool isPendingTab,
    required bool isAdmin,
  }) {
    if (videos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPendingTab ? Icons.pending_actions : Icons.video_collection_outlined,
                size: 56,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        final isPending = video.status == VideoStatus.pending;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: video.status == VideoStatus.approved
                    ? Colors.green.withValues(alpha: 0.3)
                    : video.status == VideoStatus.rejected
                        ? Colors.red.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    VideoCard(
                      video: video,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(video: video),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: video.status == VideoStatus.approved
                              ? Colors.green.withValues(alpha: 0.9)
                              : video.status == VideoStatus.rejected
                                  ? Colors.red.withValues(alpha: 0.9)
                                  : Colors.amber.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          video.status == VideoStatus.approved
                              ? 'APPROVED & LIVE'
                              : video.status == VideoStatus.rejected
                                  ? 'REJECTED'
                                  : 'PENDING MODERATION',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isAdmin && isPending) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Text(
                          'Submitter: ${video.submittedBy}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
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
                                  const SnackBar(content: Text('Video Rejected.'), backgroundColor: Colors.red),
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
                                  SnackBar(content: Text('"${video.title}" Approved!'), backgroundColor: Colors.green),
                                );
                              },
                              icon: const Icon(Icons.check, size: 14),
                              label: const Text('Approve Video', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
