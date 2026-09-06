import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../models/magazine_model.dart';
import '../../../utils/web_iframe_helper.dart';

class MagazinePdfViewerScreen extends StatefulWidget {
  final MagazineModel magazine;

  const MagazinePdfViewerScreen({super.key, required this.magazine});

  @override
  State<MagazinePdfViewerScreen> createState() => _MagazinePdfViewerScreenState();
}

class _MagazinePdfViewerScreenState extends State<MagazinePdfViewerScreen> {
  late PdfViewerController _pdfViewerController;
  late TransformationController _transformationController;
  WebViewController? _webViewController;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  bool _pdfLoadError = false;
  bool _isHtmlFlipbook = false;
  String _pdfViewType = '';
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _transformationController = TransformationController();

    String targetUrl = widget.magazine.pdfUrl.trim();
    if (targetUrl.isEmpty) {
      targetUrl = 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';
    }

    _isHtmlFlipbook = targetUrl.toLowerCase().endsWith('.html') ||
        targetUrl.toLowerCase().contains('/mobile/') ||
        targetUrl.toLowerCase().contains('aspirebookscompany') ||
        targetUrl.toLowerCase().contains('index.html');

    if (kIsWeb) {
      _pdfViewType = 'mag-pdf-iframe-${widget.magazine.id}-${DateTime.now().millisecondsSinceEpoch}';
      final embedUrl = _isHtmlFlipbook
          ? targetUrl
          : 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(targetUrl)}';
      registerIframe(_pdfViewType, embedUrl);
      _isLoading = false;
    } else if (_isHtmlFlipbook) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(targetUrl));
      _isLoading = false;
    }
  }

  Future<void> _openExternalFlipbook() async {
    final url = widget.magazine.pdfUrl.isNotEmpty
        ? widget.magazine.pdfUrl
        : 'https://aspirebookscompany.info/2025/English/2/mobile/index.html';
    final uri = Uri.parse(url);
    try {
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        } catch (_) {}
      }
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Error launching external flipbook: $e');
    }
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.magazine.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.magazine.publicationName} • ${widget.magazine.category}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open Full Interactive Flipbook',
            onPressed: _openExternalFlipbook,
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            tooltip: 'Bookmark Page',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bookmarked Page $_currentPage')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            tooltip: 'Zoom In',
            onPressed: () {
              setState(() {
                _currentScale = (_currentScale + 0.3).clamp(0.5, 4.0);
                _transformationController.value = Matrix4.identity()..scale(_currentScale);
              });
              try {
                _pdfViewerController.zoomLevel = _currentScale.clamp(1.0, 3.0);
              } catch (_) {}
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            tooltip: 'Zoom Out',
            onPressed: () {
              setState(() {
                _currentScale = (_currentScale - 0.3).clamp(0.5, 4.0);
                _transformationController.value = Matrix4.identity()..scale(_currentScale);
              });
              try {
                _pdfViewerController.zoomLevel = _currentScale.clamp(1.0, 3.0);
              } catch (_) {}
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (kIsWeb && _pdfViewType.isNotEmpty)
            InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 5.0,
              panEnabled: true,
              scaleEnabled: true,
              child: HtmlElementView(viewType: _pdfViewType),
            )
          else if (_webViewController != null)
            WebViewWidget(controller: _webViewController!)
          else
            SfPdfViewer.network(
              widget.magazine.pdfUrl.isNotEmpty
                  ? widget.magazine.pdfUrl
                  : 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
              controller: _pdfViewerController,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                setState(() {
                  _totalPages = details.document.pages.count;
                  _isLoading = false;
                });
              },
              onPageChanged: (PdfPageChangedDetails details) {
                setState(() {
                  _currentPage = details.newPageNumber;
                });
              },
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                setState(() {
                  _isLoading = false;
                  _pdfLoadError = true;
                });
              },
            ),
          if (_pdfLoadError)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.magazine.coverImageUrl,
                          width: 160,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 160,
                            height: 220,
                            color: Colors.blueGrey,
                            child: const Icon(Icons.picture_in_picture, size: 60, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.magazine.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.magazine.publicationName} • ${widget.magazine.category}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.auto_stories, color: Colors.blue),
                                SizedBox(width: 10),
                                Text(
                                  'Digital Magazine E-Reader Mode',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.magazine.description.isNotEmpty
                                  ? widget.magazine.description
                                  : 'Full issue contains featured educational articles, board preparation tips, and practice test sets.',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _pdfLoadError = false;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry Loading PDF Stream'),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: _openExternalFlipbook,
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text('Open in Browser'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_isLoading && !_pdfLoadError)
            const Center(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Opening Magazine PDF in App...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          if (!_pdfLoadError)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Page $_currentPage of ${_totalPages > 0 ? _totalPages : "..."}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
