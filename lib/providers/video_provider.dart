import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_model.dart';

final recommendedVideosProvider = FutureProvider<List<VideoModel>>((ref) async {
  return [
    VideoModel(
      id: 'v1',
      title: 'Class 10 Mathematics - Trigonometry Full Chapter',
      url: 'https://youtube.com/watch?v=1',
      platform: VideoPlatform.youtube,
      channelName: 'CBSE Master Class',
      category: 'Mathematics',
      thumbnailUrl: 'https://via.placeholder.com/300x180',
      duration: '45:20',
      viewsCount: 12400,
      status: VideoStatus.approved,
      submittedBy: 'Oxford Pub',
      submittedDate: DateTime.now(),
    ),
    VideoModel(
      id: 'v2',
      title: 'Class 10 Science - Light Reflection & Refraction',
      url: 'https://youtube.com/watch?v=2',
      platform: VideoPlatform.youtube,
      channelName: 'Science Hub',
      category: 'Science',
      thumbnailUrl: 'https://via.placeholder.com/300x180',
      duration: '32:15',
      viewsCount: 8900,
      status: VideoStatus.approved,
      submittedBy: 'Oxford Pub',
      submittedDate: DateTime.now(),
    ),
  ];
});

final recentlyViewedVideosProvider = FutureProvider<List<VideoModel>>((ref) async {
  return [
    VideoModel(
      id: 'v3',
      title: 'Hindi Chapter 1 Summary & Important Questions',
      url: 'https://youtube.com/watch?v=3',
      platform: VideoPlatform.youtube,
      channelName: 'Hindi Shiksha',
      category: 'Hindi',
      thumbnailUrl: 'https://via.placeholder.com/300x180',
      duration: '18:40',
      viewsCount: 5200,
      status: VideoStatus.approved,
      submittedBy: 'Oxford Pub',
      submittedDate: DateTime.now(),
    ),
  ];
});
