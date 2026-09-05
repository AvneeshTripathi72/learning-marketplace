import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_model.dart';

final publicRecommendedVideosProvider = FutureProvider<List<VideoModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return [
    VideoModel(
      id: 'pub_v1',
      title: 'Class 10 Chemistry - Chemical Reactions & Equations Revision',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'PW Chemistry Master',
      category: 'Chemistry',
      thumbnailUrl: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop',
      duration: '40:30',
      viewsCount: 84000,
      status: VideoStatus.approved,
      submittedBy: 'admin',
      submittedDate: DateTime.now(),
    ),
    VideoModel(
      id: 'pub_v2',
      title: 'Class 10 Maths - Quadratic Equations & Short Trick Formulae',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'PW Lakshya NEET/JEE',
      category: 'Mathematics',
      thumbnailUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=600&auto=format&fit=crop',
      duration: '48:10',
      viewsCount: 162000,
      status: VideoStatus.approved,
      submittedBy: 'admin',
      submittedDate: DateTime.now(),
    ),
  ];
});
