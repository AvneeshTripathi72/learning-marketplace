// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

void registerIframeView(String viewType, String embedUrl) {
  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      final lower = embedUrl.toLowerCase();
      final isPdf = lower.endsWith('.pdf') || lower.contains('.pdf?') || lower.contains('/ebooks/') || lower.contains('pdfviewer');
      
      final isDirectVideo = !isPdf &&
          (lower.endsWith('.mp4') ||
           lower.contains('.mp4?') ||
           lower.endsWith('.webm') ||
           lower.contains('.webm?') ||
           lower.endsWith('.mov') ||
           lower.endsWith('.mkv') ||
           lower.contains('/videos/'));

      if (isDirectVideo) {
        final videoElement = html.VideoElement()
          ..src = embedUrl
          ..controls = true
          ..autoplay = true
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain'
          ..style.pointerEvents = 'auto';
        return videoElement;
      }

      final iframe = html.IFrameElement()
        ..src = embedUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.pointerEvents = 'auto'
        ..style.touchAction = 'auto'
        ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share; fullscreen'
        ..allowFullscreen = true;
      return iframe;
    },
  );
}
