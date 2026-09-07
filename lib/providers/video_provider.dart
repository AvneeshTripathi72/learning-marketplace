import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_endpoints.dart';
import '../models/video_model.dart';

final List<VideoModel> defaultSampleVideos = [
  VideoModel(
    id: 'v_default_1',
    title: 'Class 10 Maths Lakshya Series - Trigonometry Full Chapter One-Shot',
    description: 'Complete one-shot lecture covering all trigonometric identities, board exam questions, and shortcuts.',
    url: 'https://www.youtube.com/watch?v=kffacxfA7G4',
    platform: VideoPlatform.youtube,
    channelName: 'Oxford Educational Press',
    category: 'Educational',
    subject: 'Mathematics',
    classId: 'Class 10',
    publicationName: 'Oxford Educational Press',
    thumbnailUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=600&auto=format&fit=crop',
    duration: '45:20',
    viewsCount: 142000,
    status: VideoStatus.approved,
    submittedBy: 'Oxford Faculty',
    submittedDate: DateTime.now(),
  ),
  VideoModel(
    id: 'v_default_2',
    title: 'Class 10 Science - Light Reflection & Refraction Board Exam Special',
    description: 'Detailed ray diagrams, mirror formulas, lens power numericals explained step-by-step.',
    url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    platform: VideoPlatform.youtube,
    channelName: 'Cambridge Press',
    category: 'Biology & Science',
    subject: 'Science',
    classId: 'Class 10',
    publicationName: 'Cambridge Press',
    thumbnailUrl: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop',
    duration: '38:15',
    viewsCount: 98000,
    status: VideoStatus.approved,
    submittedBy: 'Senior Educator',
    submittedDate: DateTime.now(),
  ),
  VideoModel(
    id: 'v_default_3',
    title: 'Class 10 Physics - Electricity & Circuit Numericals Masterclass',
    description: 'Ohms law, series and parallel resistor combinations, electric power numericals.',
    url: 'https://www.youtube.com/watch?v=kffacxfA7G4',
    platform: VideoPlatform.youtube,
    channelName: 'Global Science Hub',
    category: 'Informative',
    subject: 'Physics',
    classId: 'Class 10',
    publicationName: 'Global Science Hub',
    thumbnailUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600&auto=format&fit=crop',
    duration: '52:40',
    viewsCount: 115000,
    status: VideoStatus.approved,
    submittedBy: 'Science Faculty',
    submittedDate: DateTime.now(),
  ),
];

class VideoSubmissionsNotifier extends StateNotifier<List<VideoModel>> {
  VideoSubmissionsNotifier() : super(defaultSampleVideos) {
    fetchCloudQueue();
    _listenRealtime();
  }

  void _listenRealtime() {
    try {
      Supabase.instance.client
          .channel('public:Video:realtime')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'Video',
            callback: (_) => fetchCloudQueue(),
          )
          .subscribe();
    } catch (_) {}
  }

  Future<void> fetchCloudQueue() async {
    // 1. Direct Supabase PostgreSQL query
    try {
      final supabaseData = await Supabase.instance.client
          .from('Video')
          .select('*, Category(*), User(*)');

      if (supabaseData.isNotEmpty) {
        final List<VideoModel> directVideos = supabaseData.map((item) {
          final submittedUser = item['User'];
          final submitterName = submittedUser != null ? (submittedUser['name'] ?? submittedUser['email']) : 'Mobile User';

          VideoStatus vStatus = VideoStatus.pending;
          final statusStr = (item['status'] ?? '').toString().toUpperCase();
          if (statusStr == 'APPROVED' || statusStr == 'PUBLISHED') vStatus = VideoStatus.approved;
          if (statusStr == 'REJECTED') vStatus = VideoStatus.rejected;
          if (statusStr == 'DRAFT') vStatus = VideoStatus.draft;
          if (statusStr == 'ARCHIVED') vStatus = VideoStatus.archived;

          final rawUrl = (item['url'] ?? '').toString().trim();
          final validUrl = rawUrl.isNotEmpty && rawUrl.startsWith('http')
              ? rawUrl
              : 'https://www.youtube.com/watch?v=kffacxfA7G4';

          return VideoModel(
            id: item['id'].toString(),
            title: item['title'] ?? item['channelName'] ?? 'Educational Lecture Video',
            slug: item['slug'] ?? 'video-${item['id']}',
            description: item['description'] ?? 'Interactive video lecture for student learning.',
            url: validUrl,
            platform: VideoPlatform.youtube,
            channelName: item['channelName'] ?? 'Educational Channel',
            category: item['Category'] != null ? (item['Category']['name'] ?? 'Educational') : 'Educational',
            subject: item['subject'] ?? 'Mathematics',
            classId: item['classId'] ?? 'Class 10',
            publicationName: item['publicationName'] ?? 'Oxford Educational Press',
            thumbnailUrl: (item['thumbnailUrl'] != null && item['thumbnailUrl'].toString().startsWith('http'))
                ? item['thumbnailUrl']
                : 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop',
            bannerUrl: item['bannerUrl'] ?? '',
            duration: item['duration'] ?? '15:00',
            viewsCount: item['viewsCount'] ?? 1250,
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
        
        // Merge with default sample videos so there are always working videos
        final cloudIds = directVideos.map((e) => e.id).toSet();
        final remainingDefaults = defaultSampleVideos.where((d) => !cloudIds.contains(d.id)).toList();
        state = [...directVideos, ...remainingDefaults];
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

          final rawUrl = (item['url'] ?? '').toString().trim();
          final validUrl = rawUrl.isNotEmpty && rawUrl.startsWith('http')
              ? rawUrl
              : 'https://www.youtube.com/watch?v=kffacxfA7G4';

          return VideoModel(
            id: item['id'],
            title: item['title'] ?? item['channelName'] ?? 'Educational Lecture Video',
            url: validUrl,
            platform: VideoPlatform.youtube,
            channelName: item['channelName'] ?? 'Educational Channel',
            category: item['category'] != null ? (item['category']['name'] ?? 'Educational') : 'Educational',
            thumbnailUrl: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop',
            duration: '15:00',
            viewsCount: 1250,
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
        'platform': video.platform.name.toUpperCase(),
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
  return defaultSampleVideos;
});

final recentlyViewedVideosProvider = FutureProvider<List<VideoModel>>((ref) async {
  return defaultSampleVideos;
});
