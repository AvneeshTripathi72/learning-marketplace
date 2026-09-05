import 'package:flutter/material.dart';
import '../../../models/video_model.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/video_card.dart';

class PublicYoutubeScreen extends StatelessWidget {
  const PublicYoutubeScreen({super.key});

  List<VideoModel> get _publicVideos => [
    VideoModel(
      id: 'pub_v101',
      title: 'Class 10 Mathematics - Trigonometry Complete Formulae & Board Numericals',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'Oxford Science Academy',
      category: 'Mathematics',
      thumbnailUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=600&auto=format&fit=crop',
      duration: '45:20',
      viewsCount: 184000,
      status: VideoStatus.approved,
      submittedBy: 'Oxford Faculty',
      submittedDate: DateTime.now(),
    ),
    VideoModel(
      id: 'pub_v102',
      title: 'Class 10 Science - Light Reflection & Refraction Ray Diagrams Masterclass',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'Cambridge Board Batch',
      category: 'Physics',
      thumbnailUrl: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop',
      duration: '38:15',
      viewsCount: 126000,
      status: VideoStatus.approved,
      submittedBy: 'Cambridge Press',
      submittedDate: DateTime.now(),
    ),
    VideoModel(
      id: 'pub_v103',
      title: 'Class 10 Chemistry - Chemical Equations Balancing Short Tricks & Notes',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'Global Educational Hub',
      category: 'Chemistry',
      thumbnailUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600&auto=format&fit=crop',
      duration: '29:50',
      viewsCount: 95000,
      status: VideoStatus.approved,
      submittedBy: 'Senior Educator',
      submittedDate: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Educational Video Lectures'),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: _publicVideos.length,
        itemBuilder: (context, index) => VideoCard(
          video: _publicVideos[index],
        ),
      ),
    );
  }
}
