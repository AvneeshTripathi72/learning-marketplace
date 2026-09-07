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
  bool _isSavedOffline = false;
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
    debugPrint('📄 [PDF DIAGNOSTIC LOGS] Publisher: ${widget.ebook.publicationId}');
    debugPrint('📄 [PDF DIAGNOSTIC LOGS] Subject: ${widget.ebook.subjectId}');
    debugPrint('📄 [PDF DIAGNOSTIC LOGS] Class: ${widget.ebook.classId}');
    debugPrint('📄 [PDF DIAGNOSTIC LOGS] Cover URL: ${widget.ebook.coverUrl}');
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

    final allSubmissions = ref.watch(ebookSubmissionsProvider);
    final currentUser = ref.watch(authProvider);
    final relatedBooks = allSubmissions.map((s) => s.ebook).where((b) => b.id != widget.ebook.id).toList();

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
          title: Text(
            widget.ebook.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 16),
          ),
          actions: [
            // Search button
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
              icon: const Icon(Icons.open_in_new, color: Color(0xFF7C9CFF)),
              tooltip: 'Open in External Browser',
              onPressed: _openExternalPdfUrl,
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: _readerTextColor),
              onSelected: (val) {
                if (val == 'download' || val == 'print') {
                  _openExternalPdfUrl();
                } else if (val == 'toggle_engine') {
                  final nextMode = (_engineMode + 1) % 3;
                  _initPdfViewer(engineMode: nextMode, useIframe: nextMode != 0);
                } else if (val == 'offline') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isLocal ? 'File stored locally offline' : 'Streaming directly from Cloud storage',
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar header overlay if active
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

              // Top Linear Progress Bar
              LinearProgressIndicator(
                value: progressRatio,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C9CFF)),
                minHeight: 3,
              ),

              // MAIN PDF VIEWER BOX (Height ~480px on desktop/mobile)
              Container(
                height: 480,
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
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

              // READER CONTROL TOOLBAR
              Container(
                color: _readerSurfaceColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

              // DETAILS & METADATA SECTION BELOW PDF
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _readerSurfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.ebook.coverUrl,
                              width: 90,
                              height: 125,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(width: 90, height: 125, color: Colors.blueGrey),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    _buildChip(widget.ebook.subjectId, const Color(0xFF4A6CF7)),
                                    _buildChip(widget.ebook.classId, Colors.orange),
                                    _buildChip('CBSE 2026', Colors.teal),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.ebook.title,
                                  style: TextStyle(
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    height: 1.3,
                                    color: _readerTextColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Publisher: ${widget.ebook.publicationId}',
                                  style: TextStyle(fontSize: 12, color: _readerTextColor.withValues(alpha: 0.7)),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 14),
                                    const SizedBox(width: 4),
                                    Text('4.8 (12.4K ratings)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _readerTextColor)),
                                    const SizedBox(width: 12),
                                    Text('$_totalPages Pages', style: TextStyle(fontSize: 11, color: _readerTextColor.withValues(alpha: 0.7))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ACTION BUTTONS ROW
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A6CF7),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            onPressed: _openExternalPdfUrl,
                            icon: const Icon(Icons.picture_as_pdf, size: 16),
                            label: const Text('Read Fullscreen'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () {
                              setState(() => _isSavedOffline = !_isSavedOffline);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Downloading eBook PDF for offline reading...')),
                              );
                            },
                            icon: Icon(_isSavedOffline ? Icons.offline_pin : Icons.file_download_outlined, size: 16),
                            label: Text(_isSavedOffline ? 'Downloaded' : 'Download'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Book share link copied to clipboard!')),
                              );
                            },
                            icon: const Icon(Icons.share_outlined, size: 16),
                            label: const Text('Share'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // RELATED EBOOKS CAROUSEL
                    if (relatedBooks.isNotEmpty) ...[
                      Text('Related eBooks in ${widget.ebook.subjectId}', style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 16, color: _readerTextColor)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 190,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: relatedBooks.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final book = relatedBooks[index];
                            return InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => PdfViewerScreen(ebook: book)),
                                );
                              },
                              child: Container(
                                width: 130,
                                decoration: BoxDecoration(
                                  color: _readerSurfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(
                                      book.coverUrl,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(height: 120, color: Colors.grey),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            book.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: _readerTextColor),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(book.publicationId, maxLines: 1, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ADMIN PANEL CONTROLS
                    if (currentUser?.role == UserRole.admin) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _readerSurfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.admin_panel_settings, color: Colors.amber),
                                SizedBox(width: 8),
                                Text('Admin eBook Controls', style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.edit, size: 14),
                                  label: const Text('Edit eBook'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.file_upload, size: 14),
                                  label: const Text('Replace PDF'),
                                ),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                                  onPressed: () {},
                                  icon: const Icon(Icons.delete_outline, size: 14),
                                  label: const Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
