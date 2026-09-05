import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../screens/shared/video_player/video_player_screen.dart';

class VideoPlaybackResolverService {
  static void playVideo(BuildContext context, VideoModel video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(video: video),
      ),
    );
  }
}
