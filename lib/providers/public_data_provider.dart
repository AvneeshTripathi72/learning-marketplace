import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/video_model.dart';
import 'video_provider.dart';

final publicRecommendedVideosProvider = FutureProvider<List<VideoModel>>((ref) async {
  try {
    final supabaseData = await Supabase.instance.client
        .from('Video')
        .select('*, Category(*), User(*)');

    if (supabaseData is List && supabaseData.isNotEmpty) {
      final List<VideoModel> dbVideos = supabaseData
          .where((item) {
            final st = (item['status'] ?? '').toString().toUpperCase();
            return st == 'APPROVED' || st == 'PUBLISHED' || st.isEmpty;
          })
          .map((item) {
            final submittedUser = item['User'];
            final submitterName = submittedUser != null ? (submittedUser['name'] ?? submittedUser['email']) : 'Faculty User';

            return VideoModel(
              id: item['id'].toString(),
              title: item['title'] ?? item['channelName'] ?? 'Educational Lecture',
              slug: item['slug'] ?? 'video-${item['id']}',
              description: item['description'] ?? '',
              url: (item['url'] != null && item['url'].toString().startsWith('http')) ? item['url'] : 'https://www.youtube.com/watch?v=L_LUpnjgPso',
              platform: VideoPlatform.youtube,
              channelName: item['channelName'] ?? 'Educational Hub',
              category: item['Category'] != null ? (item['Category']['name'] ?? 'Educational') : 'Educational',
              subject: item['subject'] ?? 'Mathematics',
              classId: item['classId'] ?? 'Class 10',
              publicationName: item['publicationName'] ?? 'Oxford Educational Press',
              thumbnailUrl: item['thumbnailUrl'] ?? 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop',
              bannerUrl: item['bannerUrl'] ?? '',
              duration: item['duration'] ?? '15:00',
              viewsCount: item['viewsCount'] ?? 100,
              status: VideoStatus.approved,
              isFeatured: item['isFeatured'] == true,
              submittedBy: submitterName,
              submittedDate: item['submittedAt'] != null ? DateTime.parse(item['submittedAt']) : DateTime.now(),
            );
          }).toList();

      if (dbVideos.isNotEmpty) {
        return dbVideos;
      }
    }
  } catch (_) {}

  return defaultSampleVideos;
});
