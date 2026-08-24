import 'package:flutter/material.dart';
import '../../../models/video_model.dart';
import '../../../widgets/video_card.dart';

class MyUploadsScreen extends StatelessWidget {
  const MyUploadsScreen({super.key});

  final List<VideoModel> _activeVideos = const [];
  final List<VideoModel> _pendingVideos = const [];

  @override
  Widget build(BuildContext context) {
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
            _buildVideoList(_activeVideos, 'No active approved videos.'),
            _buildVideoList(_pendingVideos, 'No pending submissions.'),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoList(List<VideoModel> videos, String emptyMessage) {
    if (videos.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: videos.length,
      itemBuilder: (context, index) => VideoCard(video: videos[index], onTap: () {}),
    );
  }
}
