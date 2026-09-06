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

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _transformationController = TransformationController();
    _checkUrlValidity();

    String targetUrl = widget.ebook.fileUrl.trim();
    if (targetUrl.isEmpty) {
      targetUrl = 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';
    }

    final isHtml = targetUrl.toLowerCase().endsWith('.html') ||
        targetUrl.toLowerCase().contains('/mobile/') ||
        targetUrl.toLowerCase().contains('aspirebookscompany') ||
        targetUrl.toLowerCase().contains('index.html');

    if (kIsWeb) {
      _pdfViewType = 'ebook-pdf-iframe-${widget.ebook.id}-${DateTime.now().millisecondsSinceEpoch}';
      final embedUrl = isHtml
          ? targetUrl
          : 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(targetUrl)}';
      registerIframe(_pdfViewType, embedUrl);
      _isLoading = false;
    } else if (isHtml && !widget.ebook.isDownloaded) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(targetUrl));
      _isLoading = false;
    }
  }

  void _checkUrlValidity() {
    final url = widget.ebook.fileUrl.trim();
    if (url.isEmpty || (!url.startsWith('http://') && !url.startsWith('https://') && !widget.ebook.isDownloaded)) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Invalid or fake PDF URL link provided: "$url"';
      });
    }
  }

  Future<void> _openExternalFlipbook() async {
    final url = widget.ebook.fileUrl.isNotEmpty
        ? widget.ebook.fileUrl
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
    final isLocal = widget.ebook.isDownloaded && widget.ebook.localPath != null;

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
            tooltip: 'Open Full Interactive Reader',
            onPressed: _openExternalFlipbook,
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
                        widget.ebook.fileUrl.isNotEmpty
                            ? widget.ebook.fileUrl
                            : 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
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
                                onPressed: () {
                                  setState(() {
                                    _hasError = false;
                                    _isLoading = true;
                                  });
                                },
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Retry PDF Stream'),
                              ),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.blueAccent),
                                onPressed: _openExternalFlipbook,
                                icon: const Icon(Icons.open_in_browser, size: 16),
                                label: const Text('Open in Browser'),
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
