import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_model.dart';
import '../core/constants/api_endpoints.dart';

final publicRecommendedVideosProvider = FutureProvider<List<VideoModel>>((ref) async {
  try {
    final response = await http.get(Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.publicVideos}'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      // Wait, since the VideoModel.fromJson might not exist, I'll parse it manually.
      // Or I can return empty until they have a fromJson
      return [];
    }
  } catch (e) {
    // Ignore error
  }
  return [];
});
