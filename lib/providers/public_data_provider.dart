import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_model.dart';

final publicRecommendedVideosProvider = FutureProvider<List<VideoModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    VideoModel(
      id: 'pub_v1',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'Global Science Academy',
      category: 'Educational',
      status: VideoStatus.approved,
      submittedBy: 'admin',
      submittedDate: DateTime.now(),
    ),
    VideoModel(
      id: 'pub_v2',
      url: 'https://www.youtube.com/watch?v=3JZ_D3ELwOQ',
      platform: VideoPlatform.youtube,
      channelName: 'National Mathematics Hub',
      category: 'Educational',
      status: VideoStatus.approved,
      submittedBy: 'admin',
      submittedDate: DateTime.now(),
    ),
  ];
});
