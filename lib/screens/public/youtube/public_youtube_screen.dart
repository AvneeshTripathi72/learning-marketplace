import 'package:flutter/material.dart';
import '../../../models/video_model.dart';
import '../../../widgets/video_card.dart';
import '../../shared/video_player/video_player_screen.dart';

class PublicYoutubeScreen extends StatelessWidget {
  const PublicYoutubeScreen({super.key});

  final List<VideoModel> _publicVideos = const [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Educational Streams'),
      ),
      body: _publicVideos.isEmpty
          ? const Center(child: Text('No public streams found for selected filters.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _publicVideos.length,
              itemBuilder: (context, index) => VideoCard(
                video: _publicVideos[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerScreen(video: _publicVideos[index]),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
