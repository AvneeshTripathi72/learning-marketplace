import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_endpoints.dart';
import '../models/video_model.dart';

class VideoSubmissionsNotifier extends StateNotifier<List<VideoModel>> {
  VideoSubmissionsNotifier() : super([]) {
    fetchCloudQueue();
  }

  Future<void> fetchCloudQueue() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/video-hub/admin/queue'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List listData = jsonDecode(response.body);
        final cloudVideos = listData.map((item) {
          final submittedUser = item['submittedBy'];
          final submitterName = submittedUser != null ? (submittedUser['name'] ?? submittedUser['email']) : 'Mobile User';

          VideoStatus vStatus = VideoStatus.pending;
          if (item['status'] == 'APPROVED') vStatus = VideoStatus.approved;
          if (item['status'] == 'REJECTED') vStatus = VideoStatus.rejected;

          return VideoModel(
            id: item['id'],
            title: item['title'] ?? item['channelName'] ?? 'Uploaded Video Link',
            url: item['url'] ?? '',
            platform: VideoPlatform.youtube,
            channelName: item['channelName'] ?? 'User Channel',
            category: item['category'] != null ? (item['category']['name'] ?? 'Educational') : 'Educational',
            thumbnailUrl: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop',
            duration: '15:00',
            viewsCount: 0,
            status: vStatus,
            submittedBy: submitterName,
            submittedDate: item['submittedAt'] != null ? DateTime.parse(item['submittedAt']) : DateTime.now(),
          );
        }).toList();

        // Merge cloud videos with local state while avoiding duplicates
        final cloudIds = cloudVideos.map((e) => e.id).toSet();
        final localOnly = state.where((v) => !cloudIds.contains(v.id)).toList();

        state = [...cloudVideos, ...localOnly];
      }
    } catch (_) {}
  }

  void addVideoSubmission(VideoModel video) {
    state = [video, ...state];
  }

  Future<void> approveVideo(String videoId) async {
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

    try {
      await http.patch(
        Uri.parse('${ApiEndpoints.baseUrl}/video-hub/admin/moderate/$videoId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': 'APPROVED'}),
      ).timeout(const Duration(seconds: 8));
    } catch (_) {}
  }

  Future<void> rejectVideo(String videoId) async {
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

    try {
      await http.patch(
        Uri.parse('${ApiEndpoints.baseUrl}/video-hub/admin/moderate/$videoId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': 'REJECTED'}),
      ).timeout(const Duration(seconds: 8));
    } catch (_) {}
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
