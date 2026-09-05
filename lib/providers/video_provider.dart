import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_model.dart';

final recommendedVideosProvider = FutureProvider<List<VideoModel>>((ref) async {
  return [
    VideoModel(
      id: 'v1',
      title: 'Class 10 Maths Lakshya Series - Trigonometry Full Chapter One-Shot',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'Oxford Educational Press',
      category: 'Mathematics',
      thumbnailUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=600&auto=format&fit=crop',
      duration: '45:20',
      viewsCount: 142000,
      status: VideoStatus.approved,
      submittedBy: 'Oxford Faculty',
      submittedDate: DateTime.now(),
    ),
    VideoModel(
      id: 'v2',
      title: 'Class 10 Science - Light Reflection & Refraction Board Exam Special',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'Cambridge Press',
      category: 'Science',
      thumbnailUrl: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop',
      duration: '38:15',
      viewsCount: 98000,
      status: VideoStatus.approved,
      submittedBy: 'Senior Educator',
      submittedDate: DateTime.now(),
    ),
  ];
});

final recentlyViewedVideosProvider = FutureProvider<List<VideoModel>>((ref) async {
  return [
    VideoModel(
      id: 'v3',
      title: 'Class 10 Physics - Electricity & Circuit Numericals Masterclass',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'Global Science Hub',
      category: 'Physics',
      thumbnailUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600&auto=format&fit=crop',
      duration: '52:40',
      viewsCount: 115000,
      status: VideoStatus.approved,
      submittedBy: 'Science Faculty',
      submittedDate: DateTime.now(),
    ),
  ];
});
