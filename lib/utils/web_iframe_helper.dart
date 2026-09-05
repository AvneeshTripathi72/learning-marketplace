import 'web_iframe_stub.dart'
    if (dart.library.html) 'web_iframe_web.dart';

void registerIframe(String viewType, String embedUrl) {
  registerIframeView(viewType, embedUrl);
}
