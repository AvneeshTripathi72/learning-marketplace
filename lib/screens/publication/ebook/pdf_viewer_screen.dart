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

enum ReaderTheme { dark, light, sepia }

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfViewerController _pdfViewerController;
  late TransformationController _transformationController;
  PdfTextSearchResult _searchResult = PdfTextSearchResult();
  WebViewController? _webViewController;

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _pdfViewType = '';
  double _currentScale = 1.0;
  bool _useGoogleDocsFallback = false;
  bool _useIframe = false;

  // Reader state
  int _currentPage = 1;
  int _totalPages = 1;
  ReaderTheme _readerTheme = ReaderTheme.dark;
  bool _isBookmarked = false;
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();

  String _activeUrl = '';
  int _retryAttempt = 0;

  String _sanitizeUrl(String rawUrl) {
    const fallbackUrl = 'https://pub-0035a50eaf1046efa85b6e5d1631f721.r2.dev/ebooks/Class_10_Mathematics_Polynomials_Guide.pdf';
    var trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      return fallbackUrl;
    }
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      if (!trimmed.contains('.')) {
        return fallbackUrl;
      }
      trimmed = 'https://$trimmed';
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasAuthority || uri.host.isEmpty || !uri.host.contains('.')) {
      return fallbackUrl;
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

  int _engineMode = 0; // 0: Mozilla PDF.js, 1: Google Docs, 2: Direct Stream

  void _initPdfViewer({int? engineMode, bool useGoogleDocs = false, bool? useIframe}) {
    final targetUrl = _sanitizeUrl(widget.ebook.fileUrl);
    _activeUrl = targetUrl;
    final mode = engineMode ?? (useGoogleDocs ? 1 : 0);
    _engineMode = mode;

    final shouldIframe = useIframe ?? kIsWeb;

    if (shouldIframe) {
      if (kIsWeb) {
        _pdfViewType = 'ebook-pdf-iframe-${widget.ebook.id}-${DateTime.now().millisecondsSinceEpoch}';
        
        String embedUrl;
        if (mode == 0) {
          embedUrl = 'https://mozilla.github.io/pdf.js/web/viewer.html?file=${Uri.encodeComponent(targetUrl)}';
        } else if (mode == 1) {
          embedUrl = 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(targetUrl)}';
        } else {
          embedUrl = targetUrl;
        }

        registerIframe(_pdfViewType, embedUrl);
        setState(() {
          _isLoading = false;
          _hasError = false;
          _useGoogleDocsFallback = (mode == 1);
          _useIframe = true;
        });
      } else {
        _webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(targetUrl));
        setState(() {
          _isLoading = false;
          _hasError = false;
          _useIframe = true;
        });
      }
    } else {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _useIframe = false;
        _useGoogleDocsFallback = false;
      });
    }
  }

  void _handleDocumentLoadFailed(String description) {
    if (_retryAttempt == 0 && kIsWeb) {
      _retryAttempt = 1;
      _initPdfViewer(engineMode: 0, useIframe: true);
    } else if (_retryAttempt == 1 && kIsWeb) {
      _retryAttempt = 2;
      _initPdfViewer(engineMode: 1, useIframe: true);
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = description;
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

  void _showJumpToPageDialog() {
    final pageController = TextEditingController(text: '$_currentPage');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.numbers, color: Color(0xFF7C9CFF)),
            SizedBox(width: 10),
            Text('Go to Page', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter page number (1 - $_totalPages):', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: pageController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                hintText: 'Page number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C9CFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final page = int.tryParse(pageController.text.trim());
              if (page != null && page >= 1 && page <= _totalPages) {
                try {
                  _pdfViewerController.jumpToPage(page);
                } catch (_) {}
                Navigator.pop(ctx);
              }
            },
            child: const Text('Go', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color get _readerBgColor {
    switch (_readerTheme) {
      case ReaderTheme.light:
        return const Color(0xFFF8F9FA);
      case ReaderTheme.sepia:
        return const Color(0xFFF4ECD8);
      case ReaderTheme.dark:
        return const Color(0xFF121212);
    }
  }

  Color get _readerTextColor {
    switch (_readerTheme) {
      case ReaderTheme.light:
        return const Color(0xFF1A1A1A);
      case ReaderTheme.sepia:
        return const Color(0xFF5C4033);
      case ReaderTheme.dark:
        return const Color(0xFFE8E8E8);
    }
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    _transformationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLocal = widget.ebook.isDownloaded && widget.ebook.localPath != null;
    final targetUrl = _sanitizeUrl(widget.ebook.fileUrl);
    final progressRatio = _totalPages > 0 ? (_currentPage / _totalPages).clamp(0.0, 1.0) : 0.0;

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _readerBgColor,
        appBarTheme: AppBarTheme(
          backgroundColor: _readerBgColor == const Color(0xFF121212)
              ? const Color(0xFF1E1E1E)
              : _readerBgColor,
          elevation: 2,
          iconTheme: IconThemeData(color: _readerTextColor),
          titleTextStyle: TextStyle(color: _readerTextColor, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      child: Scaffold(
        backgroundColor: _readerBgColor,
        appBar: AppBar(
          title: Text(
            widget.ebook.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            // Search button
            IconButton(
              icon: Icon(_showSearchBar ? Icons.search_off : Icons.search, color: _readerTextColor),
              tooltip: 'Search Inside PDF',
              onPressed: () {
                setState(() {
                  _showSearchBar = !_showSearchBar;
                  if (!_showSearchBar) {
                    _searchResult.clear();
                  }
                });
              },
            ),
            // Reader theme menu
            PopupMenuButton<ReaderTheme>(
              icon: Icon(Icons.palette_outlined, color: _readerTextColor),
              tooltip: 'Reading Theme Mode',
              onSelected: (theme) => setState(() => _readerTheme = theme),
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: ReaderTheme.dark,
                  child: Row(
                    children: [
                      Icon(Icons.dark_mode, size: 18, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Dark Theme'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ReaderTheme.light,
                  child: Row(
                    children: [
                      Icon(Icons.light_mode, size: 18, color: Colors.amber),
                      SizedBox(width: 8),
                      Text('Light Theme'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ReaderTheme.sepia,
                  child: Row(
                    children: [
                      Icon(Icons.menu_book, size: 18, color: Color(0xFFC8963E)),
                      SizedBox(width: 8),
                      Text('Sepia Eye-Comfort'),
                    ],
                  ),
                ),
              ],
            ),
            // Bookmark Toggle
            IconButton(
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: _isBookmarked ? const Color(0xFFFFB84C) : _readerTextColor,
              ),
              tooltip: _isBookmarked ? 'Bookmarked' : 'Bookmark Page',
              onPressed: () {
                setState(() => _isBookmarked = !_isBookmarked);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text(
                      _isBookmarked
                          ? 'Page $_currentPage bookmarked successfully'
                          : 'Bookmark removed',
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.open_in_new, color: _readerTextColor),
              tooltip: 'Open in Browser',
              onPressed: _openExternalPdfUrl,
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: _readerTextColor),
              onSelected: (val) {
                if (val == 'download' || val == 'print') {
                  _openExternalPdfUrl();
                } else if (val == 'toggle_engine') {
                  final nextMode = (_engineMode + 1) % 3;
                  _initPdfViewer(engineMode: nextMode, useIframe: true);
                } else if (val == 'offline') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isLocal ? 'File stored locally offline' : 'Streaming directly from server',
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'toggle_engine',
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz, size: 18, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        _engineMode == 0
                            ? 'Switch to Google Docs Reader'
                            : (_engineMode == 1 ? 'Switch to Direct Stream' : 'Switch to Mozilla PDF.js Reader'),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'download',
                  child: Row(children: [Icon(Icons.download, size: 18), SizedBox(width: 8), Text('Download PDF')]),
                ),
                const PopupMenuItem(
                  value: 'print',
                  child: Row(children: [Icon(Icons.print, size: 18), SizedBox(width: 8), Text('Print Document')]),
                ),
                PopupMenuItem(
                  value: 'offline',
                  child: Row(
                    children: [
                      Icon(isLocal ? Icons.offline_pin : Icons.cloud_done, size: 18, color: isLocal ? Colors.green : Colors.blue),
                      const SizedBox(width: 8),
                      Text(isLocal ? 'Available Offline' : 'Cloud Network Stream'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar header overlay if active
            if (_showSearchBar)
              Container(
                color: _readerBgColor == const Color(0xFF121212) ? const Color(0xFF2A2A2A) : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 240,
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: _readerTextColor, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search text inside PDF...',
                            hintStyle: TextStyle(color: _readerTextColor.withValues(alpha: 0.5)),
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          onSubmitted: (text) {
                            if (text.trim().isNotEmpty) {
                              _searchResult = _pdfViewerController.searchText(text.trim());
                              setState(() {});
                            }
                          },
                        ),
                      ),
                      if (_searchResult.totalInstanceCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${_searchResult.currentInstanceIndex}/${_searchResult.totalInstanceCount}',
                            style: TextStyle(color: _readerTextColor, fontSize: 12),
                          ),
                        ),
                      IconButton(
                        icon: Icon(Icons.navigate_before, color: _readerTextColor),
                        onPressed: () => _searchResult.previousInstance(),
                      ),
                      IconButton(
                        icon: Icon(Icons.navigate_next, color: _readerTextColor),
                        onPressed: () => _searchResult.nextInstance(),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: _readerTextColor),
                        onPressed: () {
                          _searchController.clear();
                          _searchResult.clear();
                          setState(() => _showSearchBar = false);
                        },
                      ),
                    ],
                  ),
                ),
              ),

            // Top Linear Progress Bar
            LinearProgressIndicator(
              value: progressRatio,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C9CFF)),
              minHeight: 3,
            ),

            // Viewer Content
            Expanded(
              child: Stack(
                children: [
                  if (!_hasError)
                    _useIframe && kIsWeb && _pdfViewType.isNotEmpty
                        ? SizedBox.expand(
                            child: HtmlElementView(viewType: _pdfViewType),
                          )
                        : _webViewController != null
                            ? WebViewWidget(controller: _webViewController!)
                            : isLocal
                                ? SfPdfViewer.file(
                                    File(widget.ebook.localPath!),
                                    controller: _pdfViewerController,
                                    onPageChanged: (details) {
                                      setState(() {
                                        _currentPage = details.newPageNumber;
                                      });
                                    },
                                    onDocumentLoaded: (details) {
                                      setState(() {
                                        _isLoading = false;
                                        _totalPages = details.document.pages.count;
                                      });
                                    },
                                    onDocumentLoadFailed: (details) {
                                      setState(() {
                                        _isLoading = false;
                                        _hasError = true;
                                        _errorMessage = details.description;
                                      });
                                    },
                                  )
                                : SfPdfViewer.network(
                                    _activeUrl.isNotEmpty ? _activeUrl : targetUrl,
                                    controller: _pdfViewerController,
                                    onPageChanged: (details) {
                                      setState(() {
                                        _currentPage = details.newPageNumber;
                                      });
                                    },
                                    onDocumentLoaded: (details) {
                                      setState(() {
                                        _isLoading = false;
                                        _hasError = false;
                                        _totalPages = details.document.pages.count;
                                      });
                                    },
                                    onDocumentLoadFailed: (details) {
                                      _handleDocumentLoadFailed(details.description);
                                    },
                                  ),
                  if (_isLoading && !_hasError)
                    const Center(
                      child: Card(
                        elevation: 4,
                        color: Color(0xFF1E1E1E),
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Color(0xFF7C9CFF)),
                              SizedBox(height: 12),
                              Text('Opening eBook Document...', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                            color: const Color(0xFF1E1E1E),
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
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
                                      color: const Color(0xFF7C9CFF).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFF7C9CFF).withValues(alpha: 0.3)),
                                    ),
                                    child: const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.menu_book, color: Color(0xFF7C9CFF), size: 18),
                                            SizedBox(width: 8),
                                            Text('In-App Reader Engine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Interactive eBook edition containing complete textbook chapters, practice questions, and board exam solutions.',
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
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
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C9CFF), foregroundColor: Colors.white),
                                        onPressed: _openExternalPdfUrl,
                                        icon: const Icon(Icons.open_in_new, size: 16),
                                        label: const Text('Open in Browser Tab'),
                                      ),
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF7C9CFF)),
                                        onPressed: () {
                                          _initPdfViewer(useGoogleDocs: !_useGoogleDocsFallback, useIframe: true);
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
            ),

            // Bottom Navigation & Reader Control Toolbar
            Container(
              color: _readerBgColor == const Color(0xFF121212)
                  ? const Color(0xFF1E1E1E)
                  : _readerBgColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous Page button
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, size: 18, color: _readerTextColor),
                        tooltip: 'Previous Page',
                        onPressed: () {
                          try {
                            _pdfViewerController.previousPage();
                          } catch (_) {}
                        },
                      ),

                      // Page counter indicator & Jump to Page button
                      InkWell(
                        onTap: _showJumpToPageDialog,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: _readerTextColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _readerTextColor.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Page $_currentPage of $_totalPages',
                                style: TextStyle(color: _readerTextColor, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.unfold_more, size: 16, color: _readerTextColor.withValues(alpha: 0.7)),
                            ],
                          ),
                        ),
                      ),

                      // Zoom Out / Scale indicator / Zoom In
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, size: 20, color: _readerTextColor),
                            tooltip: 'Zoom Out',
                            onPressed: () {
                              setState(() {
                                _currentScale = (_currentScale - 0.25).clamp(0.5, 4.0);
                                _transformationController.value = Matrix4.diagonal3Values(_currentScale, _currentScale, 1.0);
                              });
                              try {
                                _pdfViewerController.zoomLevel = _currentScale.clamp(1.0, 3.0);
                              } catch (_) {}
                            },
                          ),
                          Text(
                            '${(_currentScale * 100).toInt()}%',
                            style: TextStyle(color: _readerTextColor.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, size: 20, color: _readerTextColor),
                            tooltip: 'Zoom In',
                            onPressed: () {
                              setState(() {
                                _currentScale = (_currentScale + 0.25).clamp(0.5, 4.0);
                                _transformationController.value = Matrix4.diagonal3Values(_currentScale, _currentScale, 1.0);
                              });
                              try {
                                _pdfViewerController.zoomLevel = _currentScale.clamp(1.0, 3.0);
                              } catch (_) {}
                            },
                          ),
                        ],
                      ),

                      // Next Page button
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios, size: 18, color: _readerTextColor),
                        tooltip: 'Next Page',
                        onPressed: () {
                          try {
                            _pdfViewerController.nextPage();
                          } catch (_) {}
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
