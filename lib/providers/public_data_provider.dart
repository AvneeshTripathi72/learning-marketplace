import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_model.dart';

final publicRecommendedVideosProvider = FutureProvider<List<VideoModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    VideoModel(
      id: 'pub_v1',
      title: 'Global Science Experiments & Fundamentals',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'Global Science Academy',
      category: 'Educational',
      thumbnailUrl: 'https://via.placeholder.com/300x180',
      duration: '15:30',
      viewsCount: 4200,
      status: VideoStatus.approved,
      submittedBy: 'admin',
      submittedDate: DateTime.now(),
    ),
    VideoModel(
      id: 'pub_v2',
      title: 'National Mathematics Olympiad Preparation',
      url: 'https://www.youtube.com/watch?v=3JZ_D3ELwOQ',
      platform: VideoPlatform.youtube,
      channelName: 'National Mathematics Hub',
      category: 'Educational',
      thumbnailUrl: 'https://via.placeholder.com/300x180',
      duration: '22:10',
      viewsCount: 8100,
      status: VideoStatus.approved,
      submittedBy: 'admin',
      submittedDate: DateTime.now(),
    ),
  ];
});
