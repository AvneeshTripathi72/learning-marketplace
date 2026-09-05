import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/video_model.dart';
import '../../../providers/video_provider.dart';
import '../../../widgets/video_card.dart';

class MyUploadsScreen extends ConsumerWidget {
  const MyUploadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissions = ref.watch(videoSubmissionsProvider);

    final activeVideos = submissions.where((v) => v.status == VideoStatus.approved).toList();
    final pendingVideos = submissions.where((v) => v.status == VideoStatus.pending || v.status == VideoStatus.rejected).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Uploaded Videos'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active Videos'),
              Tab(text: 'Inactive / Pending'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildVideoList(activeVideos, 'No active approved videos.', isPendingTab: false),
            _buildVideoList(pendingVideos, 'No pending submissions in queue.', isPendingTab: true),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoList(List<VideoModel> videos, String emptyMessage, {required bool isPendingTab}) {
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
      padding: const EdgeInsets.all(12),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Stack(
            children: [
              VideoCard(video: video, onTap: () {}),
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
        );
      },
    );
  }
}
