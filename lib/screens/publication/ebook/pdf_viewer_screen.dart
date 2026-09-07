import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../models/ebook_model.dart';
import '../../../utils/web_iframe_helper.dart';

class PdfViewerScreen extends StatefulWidget {
  final EBookModel ebook;

  const PdfViewerScreen({super.key, required this.ebook});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfViewerController _pdfViewerController;
  late TransformationController _transformationController;
  WebViewController? _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _pdfViewType = '';
  double _currentScale = 1.0;
  bool _useGoogleDocsFallback = false;

  String _sanitizeUrl(String rawUrl) {
    var trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      return 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';
    }
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'https://$trimmed';
    }
    // Auto-convert Google Drive view links to iframe-compatible preview links
    if (trimmed.contains('drive.google.com') && trimmed.contains('/view')) {
      trimmed = trimmed.replaceAll('/view', '/preview');
    }
    return trimmed;
  }

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _transformationController = TransformationController();
    _initPdfViewer();
  }

  void _initPdfViewer({bool useGoogleDocs = false}) {
    final targetUrl = _sanitizeUrl(widget.ebook.fileUrl);

    final isHtml = targetUrl.toLowerCase().endsWith('.html') ||
        targetUrl.toLowerCase().contains('/mobile/') ||
        targetUrl.toLowerCase().contains('aspirebookscompany') ||
        targetUrl.toLowerCase().contains('index.html');

    if (kIsWeb) {
      _pdfViewType = 'ebook-pdf-iframe-${widget.ebook.id}-${DateTime.now().millisecondsSinceEpoch}';
      final embedUrl = useGoogleDocs
          ? 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(targetUrl)}'
          : targetUrl;
      registerIframe(_pdfViewType, embedUrl);
      setState(() {
        _isLoading = false;
        _hasError = false;
        _useGoogleDocsFallback = useGoogleDocs;
      });
    } else if (isHtml && !widget.ebook.isDownloaded) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(targetUrl));
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } else {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }
  }

  Future<void> _openExternalPdfUrl() async {
    final targetUrl = _sanitizeUrl(widget.ebook.fileUrl);
    final uri = Uri.parse(targetUrl);
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
      debugPrint('Error launching external URL: $e');
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
    final isLocal = widget.ebook.isDownloaded && widget.ebook.localPath != null;
    final targetUrl = _sanitizeUrl(widget.ebook.fileUrl);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.ebook.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open in Browser Tab',
            onPressed: _openExternalPdfUrl,
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
          IconButton(
            icon: Icon(
              isLocal ? Icons.offline_pin : Icons.cloud_done,
              color: isLocal ? Colors.green : Colors.blue,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isLocal ? 'File available offline' : 'Streaming eBook document from server',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_hasError)
            kIsWeb && _pdfViewType.isNotEmpty
                ? InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.5,
                    maxScale: 5.0,
                    panEnabled: true,
                    scaleEnabled: true,
                    child: HtmlElementView(viewType: _pdfViewType),
                  )
                : _webViewController != null
                    ? WebViewWidget(controller: _webViewController!)
                    : isLocal
                        ? SfPdfViewer.file(
                            File(widget.ebook.localPath!),
                            controller: _pdfViewerController,
                            onDocumentLoaded: (_) => setState(() => _isLoading = false),
                            onDocumentLoadFailed: (details) {
                              setState(() {
                                _isLoading = false;
                                _hasError = true;
                                _errorMessage = details.description;
                              });
                            },
                          )
                        : SfPdfViewer.network(
                            targetUrl,
                            controller: _pdfViewerController,
                            onDocumentLoaded: (_) => setState(() => _isLoading = false),
                            onDocumentLoadFailed: (details) {
                              setState(() {
                                _isLoading = false;
                                _hasError = true;
                                _errorMessage = details.description;
                              });
                            },
                          ),
          if (_isLoading && !_hasError)
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
                      Text('Opening eBook PDF Document...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.ebook.coverUrl,
                              width: 120,
                              height: 160,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 120,
                                height: 160,
                                color: Colors.blueGrey,
                                child: const Icon(Icons.picture_as_pdf, size: 48, color: Colors.redAccent),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.ebook.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Class ${widget.ebook.classId} • Publisher: ${widget.ebook.publicationId}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          if (_errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.menu_book, color: Colors.blue, size: 18),
                                    SizedBox(width: 8),
                                    Text('In-App eBook Digital Reader', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Interactive eBook edition containing complete textbook chapters, practice questions, and board exam solutions.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                                onPressed: _openExternalPdfUrl,
                                icon: const Icon(Icons.open_in_new, size: 16),
                                label: const Text('Open in Browser Tab'),
                              ),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.blueAccent),
                                onPressed: () {
                                  _initPdfViewer(useGoogleDocs: !_useGoogleDocsFallback);
                                },
                                icon: const Icon(Icons.refresh, size: 16),
                                label: Text(_useGoogleDocsFallback ? 'Use Direct Stream' : 'Use Google Docs Reader'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

