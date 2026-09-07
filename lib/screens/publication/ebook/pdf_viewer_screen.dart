import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../models/ebook_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/ebook_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/web_iframe_helper.dart';

enum ReaderTheme { dark, light, sepia }

class PdfViewerScreen extends ConsumerStatefulWidget {
  final EBookModel ebook;

  const PdfViewerScreen({super.key, required this.ebook});

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
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
  int _engineMode = 0; // 0: Native SfPdfViewer, 1: Mozilla PDF.js, 2: Google Docs

  String _sanitizeUrl(String rawUrl) {
    const fallbackUrl = 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';
    var trimmed = rawUrl.trim();
    if (trimmed.isEmpty || trimmed.length < 5) {
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
    _printDiagnosticLogs();
    _initPdfViewer();
  }

  void _printDiagnosticLogs() {
    final targetUrl = _sanitizeUrl(widget.ebook.fileUrl);
    debugPrint('📄 ===================================================');
    debugPrint('📄 [PDF DIAGNOSTIC LOGS] eBook ID: ${widget.ebook.id}');
    debugPrint('📄 [PDF DIAGNOSTIC LOGS] Title: ${widget.ebook.title}');
    debugPrint('📄 [PDF DIAGNOSTIC LOGS] Raw File URL: "${widget.ebook.fileUrl}"');
    debugPrint('📄 [PDF DIAGNOSTIC LOGS] Sanitized URL: "$targetUrl"');
    debugPrint('📄 ===================================================');
  }

  void _initPdfViewer({int? engineMode, bool useGoogleDocs = false, bool? useIframe}) {
    final targetUrl = _sanitizeUrl(widget.ebook.fileUrl);
    _activeUrl = targetUrl;
    final mode = engineMode ?? (useGoogleDocs ? 2 : 0);
    _engineMode = mode;

    final shouldIframe = useIframe ?? (kIsWeb && mode != 0);

    if (shouldIframe) {
      if (kIsWeb) {
        _pdfViewType = 'ebook-pdf-iframe-${widget.ebook.id}-${DateTime.now().millisecondsSinceEpoch}';
        
        String embedUrl;
        if (mode == 1) {
          embedUrl = 'https://mozilla.github.io/pdf.js/web/viewer.html?file=${Uri.encodeComponent(targetUrl)}';
        } else if (mode == 2) {
          embedUrl = 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(targetUrl)}';
        } else {
          embedUrl = targetUrl;
        }

        registerIframe(_pdfViewType, embedUrl);
        setState(() {
          _isLoading = false;
          _hasError = false;
          _useGoogleDocsFallback = (mode == 2);
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
    debugPrint('⚠️ [PDF Viewer Load Failed] Attempt $_retryAttempt: $description');
    if (_retryAttempt == 0 && kIsWeb) {
      _retryAttempt = 1;
      _initPdfViewer(engineMode: 1, useIframe: true);
    } else if (_retryAttempt == 1 && kIsWeb) {
      _retryAttempt = 2;
      _initPdfViewer(engineMode: 2, useIframe: true);
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = description.isNotEmpty ? description : 'Failed to parse stream format. Check CORS or URL access.';
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

  Color get _readerSurfaceColor {
    switch (_readerTheme) {
      case ReaderTheme.light:
        return Colors.white;
      case ReaderTheme.sepia:
        return const Color(0xFFEFE6CE);
      case ReaderTheme.dark:
        return const Color(0xFF1E1E1E);
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
          backgroundColor: _readerSurfaceColor,
          elevation: 1,
          iconTheme: IconThemeData(color: _readerTextColor),
          titleTextStyle: TextStyle(color: _readerTextColor, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      child: Scaffold(
        backgroundColor: _readerBgColor,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.ebook.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                '${widget.ebook.subjectId} • ${widget.ebook.classId} • ${widget.ebook.publicationId}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, color: _readerTextColor.withValues(alpha: 0.7)),
              ),
            ],
          ),
          actions: [
            // Upper Section Navigation: Page Counter & Prev / Next Page Controls
            if (!_useIframe) ...[
              IconButton(
                icon: const Icon(Icons.navigate_before, size: 22),
                tooltip: 'Previous Page',
                onPressed: () {
                  try {
                    _pdfViewerController.previousPage();
                  } catch (_) {}
                },
              ),
              InkWell(
                onTap: _showJumpToPageDialog,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _readerTextColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_currentPage/$_totalPages',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _readerTextColor),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.navigate_next, size: 22),
                tooltip: 'Next Page',
                onPressed: () {
                  try {
                    _pdfViewerController.nextPage();
                  } catch (_) {}
                },
              ),

              // Zoom Controls
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                tooltip: 'Zoom Out',
                onPressed: () {
                  setState(() {
                    _currentScale = (_currentScale - 0.25).clamp(0.5, 4.0);
                  });
                  try {
                    _pdfViewerController.zoomLevel = _currentScale.clamp(1.0, 3.0);
                  } catch (_) {}
                },
              ),
              Text(
                '${(_currentScale * 100).toInt()}%',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _readerTextColor.withValues(alpha: 0.8)),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                tooltip: 'Zoom In',
                onPressed: () {
                  setState(() {
                    _currentScale = (_currentScale + 0.25).clamp(0.5, 4.0);
                  });
                  try {
                    _pdfViewerController.zoomLevel = _currentScale.clamp(1.0, 3.0);
                  } catch (_) {}
                },
              ),
            ],

            // Search Button
            IconButton(
              icon: Icon(_showSearchBar ? Icons.search_off : Icons.search, color: _readerTextColor),
              tooltip: 'Search Text inside PDF',
              onPressed: () {
                setState(() {
                  _showSearchBar = !_showSearchBar;
                  if (!_showSearchBar) {
                    _searchResult.clear();
                  }
                });
              },
            ),

            // Reading Theme Menu (Dark, Light, Sepia)
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
                      _isBookmarked ? 'Page $_currentPage bookmarked successfully' : 'Bookmark removed',
                    ),
                  ),
                );
              },
            ),

            // Open in External Browser
            IconButton(
              icon: const Icon(Icons.open_in_new, color: Color(0xFF7C9CFF)),
              tooltip: 'Open in External Browser',
              onPressed: _openExternalPdfUrl,
            ),

            // Popup Options
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: _readerTextColor),
              onSelected: (val) {
                if (val == 'download' || val == 'print') {
                  _openExternalPdfUrl();
                } else if (val == 'toggle_engine') {
                  final nextMode = (_engineMode + 1) % 3;
                  _initPdfViewer(engineMode: nextMode, useIframe: nextMode != 0);
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
                            ? 'Switch to Mozilla PDF.js Reader'
                            : (_engineMode == 1 ? 'Switch to Google Docs Reader' : 'Switch to Direct Stream Engine'),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'download',
                  child: Row(children: [Icon(Icons.download, size: 18), SizedBox(width: 8), Text('Download PDF Package')]),
                ),
                const PopupMenuItem(
                  value: 'print',
                  child: Row(children: [Icon(Icons.print, size: 18), SizedBox(width: 8), Text('Print Document')]),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar Header Overlay if Active
            if (_showSearchBar)
              Container(
                color: _readerSurfaceColor,
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

            // Linear Reading Progress Indicator
            LinearProgressIndicator(
              value: progressRatio,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C9CFF)),
              minHeight: 3,
            ),

            // FULLSCREEN EDGE-TO-EDGE PDF VIEWER CONTAINER (Takes 100% remaining screen height)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(0),
                ),
                clipBehavior: Clip.antiAlias,
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
                                SizedBox(height: 10),
                                Text('Loading PDF Document...', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                                        width: 100,
                                        height: 140,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 100,
                                          height: 140,
                                          color: Colors.blueGrey,
                                          child: const Icon(Icons.picture_as_pdf, size: 48, color: Colors.redAccent),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      widget.ebook.title,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${widget.ebook.subjectId} • ${widget.ebook.classId}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                                          label: Text(_useGoogleDocsFallback ? 'Use Direct Stream' : 'Use Google Reader'),
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
            ),
          ],
        ),
      ),
    );
  }
}
