import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_endpoints.dart';
import '../models/video_model.dart';

class VideoSubmissionsNotifier extends StateNotifier<List<VideoModel>> {
  VideoSubmissionsNotifier() : super([]) {
    fetchCloudQueue();
  }

  Future<void> fetchCloudQueue() async {
    // 1. Direct Supabase PostgreSQL query
    try {
      final supabaseData = await Supabase.instance.client
          .from('Video')
          .select('*, Category(*), User(*)');

      if (supabaseData is List && supabaseData.isNotEmpty) {
        final List<VideoModel> directVideos = supabaseData.map((item) {
          final submittedUser = item['User'];
          final submitterName = submittedUser != null ? (submittedUser['name'] ?? submittedUser['email']) : 'Mobile User';

          VideoStatus vStatus = VideoStatus.pending;
          final statusStr = (item['status'] ?? '').toString().toUpperCase();
          if (statusStr == 'APPROVED' || statusStr == 'PUBLISHED') vStatus = VideoStatus.approved;
          if (statusStr == 'REJECTED') vStatus = VideoStatus.rejected;
          if (statusStr == 'DRAFT') vStatus = VideoStatus.draft;
          if (statusStr == 'ARCHIVED') vStatus = VideoStatus.archived;

          return VideoModel(
            id: item['id'].toString(),
            title: item['title'] ?? item['channelName'] ?? 'Uploaded Video Link',
            slug: item['slug'] ?? 'video-${item['id']}',
            description: item['description'] ?? '',
            url: item['url'] ?? '',
            platform: VideoPlatform.youtube,
            channelName: item['channelName'] ?? 'User Channel',
            category: item['Category'] != null ? (item['Category']['name'] ?? 'Educational') : 'Educational',
            subject: item['subject'] ?? 'Mathematics',
            classId: item['classId'] ?? 'Class 10',
            publicationName: item['publicationName'] ?? 'Oxford Educational Press',
            thumbnailUrl: item['thumbnailUrl'] ?? 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop',
            bannerUrl: item['bannerUrl'] ?? '',
            duration: item['duration'] ?? '15:00',
            viewsCount: item['viewsCount'] ?? 0,
            status: vStatus,
            isFeatured: item['isFeatured'] == true,
            submittedBy: submitterName,
            submittedDate: item['submittedAt'] != null ? DateTime.parse(item['submittedAt']) : DateTime.now(),
            seoTitle: item['seoTitle'],
            seoKeywords: item['seoKeywords'],
            seoDescription: item['seoDescription'],
          );
        }).toList();

        debugPrint('⚡ Loaded ${directVideos.length} videos directly from Supabase DB Video table');
        state = directVideos;
        return;
      }
    } catch (e) {
      debugPrint('ℹ️ Direct Supabase fetch note: $e');
    }

    // 2. HTTP Backend fallback
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
          final statusStr = (item['status'] ?? '').toString().toUpperCase();
          if (statusStr == 'APPROVED' || statusStr == 'PUBLISHED') vStatus = VideoStatus.approved;
          if (statusStr == 'REJECTED') vStatus = VideoStatus.rejected;
          if (statusStr == 'DRAFT') vStatus = VideoStatus.draft;

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

        final cloudIds = cloudVideos.map((e) => e.id).toSet();
        final localOnly = state.where((v) => !cloudIds.contains(v.id)).toList();

        state = [...cloudVideos, ...localOnly];
      }
    } catch (_) {}
  }

  Future<void> addVideoSubmission(VideoModel video) async {
    state = [video, ...state];
    try {
      await Supabase.instance.client.from('Video').insert({
        'url': video.url,
        'platform': video.platform.name,
        'channelName': video.channelName,
        'status': video.status == VideoStatus.approved ? 'APPROVED' : (video.status == VideoStatus.draft ? 'DRAFT' : 'PENDING'),
      });
      debugPrint('⚡ Video inserted into Supabase DB Video table');
    } catch (e) {
      debugPrint('ℹ️ Supabase Video insert note: $e');
    }
  }

  Future<void> updateVideo(VideoModel updatedVideo) async {
    state = state.map((v) => v.id == updatedVideo.id ? updatedVideo : v).toList();

    try {
      await Supabase.instance.client.from('Video').update({
        'url': updatedVideo.url,
        'channelName': updatedVideo.channelName,
        'status': updatedVideo.status == VideoStatus.approved ? 'APPROVED' : updatedVideo.status.name.toUpperCase(),
      }).eq('id', updatedVideo.id);
      debugPrint('⚡ Video updated in Supabase DB');
    } catch (e) {
      debugPrint('ℹ️ Supabase Video update note: $e');
    }
  }

  Future<void> deleteVideo(String videoId) async {
    state = state.where((v) => v.id != videoId).toList();
    try {
      await Supabase.instance.client.from('Video').delete().eq('id', videoId);
      debugPrint('⚡ Video deleted from Supabase DB');
    } catch (e) {
      debugPrint('ℹ️ Supabase Video delete note: $e');
    }
  }

  Future<void> bulkDeleteVideos(List<String> videoIds) async {
    final idsSet = videoIds.toSet();
    state = state.where((v) => !idsSet.contains(v.id)).toList();
    try {
      await Supabase.instance.client.from('Video').delete().inFilter('id', videoIds);
      debugPrint('⚡ Bulk deleted ${videoIds.length} videos from Supabase DB');
    } catch (e) {
      debugPrint('ℹ️ Supabase Video bulk delete note: $e');
    }
  }

  Future<void> bulkUpdateVideoStatus(List<String> videoIds, VideoStatus newStatus) async {
    final idsSet = videoIds.toSet();
    state = state.map((v) {
      if (idsSet.contains(v.id)) {
        return v.copyWith(status: newStatus);
      }
      return v;
    }).toList();

    String statusStr = 'APPROVED';
    if (newStatus == VideoStatus.draft) statusStr = 'DRAFT';
    if (newStatus == VideoStatus.archived) statusStr = 'ARCHIVED';
    if (newStatus == VideoStatus.pending) statusStr = 'PENDING';

    try {
      await Supabase.instance.client
          .from('Video')
          .update({'status': statusStr})
          .inFilter('id', videoIds);
      debugPrint('⚡ Bulk status updated to $statusStr in Supabase DB');
    } catch (e) {
      debugPrint('ℹ️ Supabase Video bulk status update note: $e');
    }
  }

  Future<void> toggleVideoFeatured(String videoId) async {
    state = state.map((v) {
      if (v.id == videoId) {
        return v.copyWith(isFeatured: !v.isFeatured);
      }
      return v;
    }).toList();
  }

  Future<void> approveVideo(String videoId) async {
    state = state.map((v) {
      if (v.id == videoId) {
        return v.copyWith(status: VideoStatus.approved);
      }
      return v;
    }).toList();

    try {
      await Supabase.instance.client
          .from('Video')
          .update({'status': 'APPROVED'})
          .eq('id', videoId);
    } catch (_) {}
  }

  Future<void> rejectVideo(String videoId) async {
    state = state.map((v) {
      if (v.id == videoId) {
        return v.copyWith(status: VideoStatus.rejected);
      }
      return v;
    }).toList();

    try {
      await Supabase.instance.client
          .from('Video')
          .update({'status': 'REJECTED'})
          .eq('id', videoId);
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
