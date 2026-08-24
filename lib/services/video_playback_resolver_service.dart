import 'package:url_launcher/url_launcher.dart';
import '../models/video_model.dart';

class VideoPlaybackResolverService {
  static Future<void> playVideo(VideoModel video) async {
    final uri = Uri.parse(video.url);

    switch (video.platform) {
      case VideoPlatform.youtube:
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;

      case VideoPlatform.instagram:
      case VideoPlatform.facebook:
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
        }
        break;
    }
  }
}
