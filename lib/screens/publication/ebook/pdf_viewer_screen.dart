import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../models/ebook_model.dart';

class PdfViewerScreen extends StatefulWidget {
  final EBookModel ebook;

  const PdfViewerScreen({super.key, required this.ebook});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfViewerController _pdfViewerController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _checkUrlValidity();
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

  @override
  void dispose() {
    _pdfViewerController.dispose();
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
            isLocal
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
                    widget.ebook.fileUrl,
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
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.picture_as_pdf, size: 64, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        const Text(
                          'Unable to Load PDF Document',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'The provided PDF document link is broken, invalid, or fake.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage.isNotEmpty
                                ? _errorMessage
                                : (widget.ebook.fileUrl.isNotEmpty ? widget.ebook.fileUrl : 'URL is empty'),
                            style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.red),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _hasError = false;
                              _isLoading = true;
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry Loading'),
                        ),
                      ],
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
