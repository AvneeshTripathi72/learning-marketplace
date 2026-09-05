import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_model.dart';

class VideoSubmissionsNotifier extends StateNotifier<List<VideoModel>> {
  VideoSubmissionsNotifier()
      : super([
          VideoModel(
            id: 'sub_v0',
            title: 'CBSE Class 10 Board Exam Mathematics Masterclass',
            url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
            platform: VideoPlatform.youtube,
            channelName: 'Oxford Educational Press',
            category: 'Mathematics',
            thumbnailUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=600&auto=format&fit=crop',
            duration: '42:10',
            viewsCount: 5400,
            status: VideoStatus.approved,
            submittedBy: 'Vendor (Oxford)',
            submittedDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
          VideoModel(
            id: 'sub_v1',
            title: 'Class 10 Physics - Light Reflection & Refraction Formulae',
            url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
            platform: VideoPlatform.youtube,
            channelName: 'Global Science Academy',
            category: 'Educational',
            thumbnailUrl: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop',
            duration: '35:40',
            viewsCount: 1200,
            status: VideoStatus.pending,
            submittedBy: 'Public User (Rahul)',
            submittedDate: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          VideoModel(
            id: 'sub_v2',
            title: 'Class 12 Organic Chemistry Mechanisms Masterclass',
            url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
            platform: VideoPlatform.youtube,
            channelName: 'Chemistry Simplified',
            category: 'Educational',
            thumbnailUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600&auto=format&fit=crop',
            duration: '48:15',
            viewsCount: 3400,
            status: VideoStatus.pending,
            submittedBy: 'Vendor (Oxford)',
            submittedDate: DateTime.now().subtract(const Duration(hours: 5)),
          ),
        ]);

  void addVideoSubmission(VideoModel video) {
    state = [video, ...state];
  }

  void approveVideo(String videoId) {
    state = state.map((v) {
      if (v.id == videoId) {
        return VideoModel(
          id: v.id,
          title: v.title,
          url: v.url,
          platform: v.platform,
          channelName: v.channelName,
          category: v.category,
          thumbnailUrl: v.thumbnailUrl,
          duration: v.duration,
          viewsCount: v.viewsCount,
          status: VideoStatus.approved,
          submittedBy: v.submittedBy,
          submittedDate: v.submittedDate,
        );
      }
      return v;
    }).toList();
  }

  void rejectVideo(String videoId) {
    state = state.map((v) {
      if (v.id == videoId) {
        return VideoModel(
          id: v.id,
          title: v.title,
          url: v.url,
          platform: v.platform,
          channelName: v.channelName,
          category: v.category,
          thumbnailUrl: v.thumbnailUrl,
          duration: v.duration,
          viewsCount: v.viewsCount,
          status: VideoStatus.rejected,
          submittedBy: v.submittedBy,
          submittedDate: v.submittedDate,
        );
      }
      return v;
    }).toList();
  }
}

final videoSubmissionsProvider = StateNotifierProvider<VideoSubmissionsNotifier, List<VideoModel>>((ref) {
  return VideoSubmissionsNotifier();
});

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
