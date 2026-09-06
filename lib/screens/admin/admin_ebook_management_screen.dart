import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/ebook_model.dart';
import '../../providers/ebook_provider.dart';
import '../../services/storage_service.dart';
import '../publication/ebook/pdf_viewer_screen.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/core/blurred_drawer_scaffold.dart';

class AdminEBookManagementScreen extends ConsumerStatefulWidget {
  const AdminEBookManagementScreen({super.key});

  @override
  ConsumerState<AdminEBookManagementScreen> createState() => _AdminEBookManagementScreenState();
}

class _AdminEBookManagementScreenState extends ConsumerState<AdminEBookManagementScreen> {
  String _searchQuery = '';
  String _statusFilter = 'ALL';
  String _pricingFilter = 'ALL'; // ALL, FREE, PAID
  bool _featuredOnlyFilter = false;
  String _sortBy = 'NEWEST';

  final Set<String> _selectedEBookIds = {};
  int _currentPage = 1;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(ebookSubmissionsProvider.notifier).fetchCloudEBooks();
    });
  }

  void _showAddEditEBookDialog([EBookModel? existingEBook]) {
    final isEdit = existingEBook != null;
    final titleCtrl = TextEditingController(text: existingEBook?.title ?? '');
    final slugCtrl = TextEditingController(text: existingEBook?.slug ?? '');
    final authorCtrl = TextEditingController(text: existingEBook?.author ?? 'Academic Editorial Board');
    final descCtrl = TextEditingController(text: existingEBook?.description ?? '');
    final priceCtrl = TextEditingController(text: existingEBook?.price.toString() ?? '0.0');
    final discountCtrl = TextEditingController(text: existingEBook?.discountPrice.toString() ?? '0.0');
    final coverCtrl = TextEditingController(text: existingEBook?.coverUrl ?? '');
    final fileCtrl = TextEditingController(text: existingEBook?.fileUrl ?? '');
    final seoTitleCtrl = TextEditingController(text: existingEBook?.seoTitle ?? '');
    final seoKeywordsCtrl = TextEditingController(text: existingEBook?.seoKeywords ?? '');
    final seoDescCtrl = TextEditingController(text: existingEBook?.seoDescription ?? '');

    String publication = existingEBook?.publicationId ?? 'Oxford Educational Press';
    String series = existingEBook?.seriesId ?? 'CBSE Standard 2026';
    String classId = existingEBook?.classId ?? 'Class 10';
    String subject = existingEBook?.subjectId ?? 'Mathematics';
    EBookAdminStatus status = existingEBook?.status ?? EBookAdminStatus.published;
    bool isFree = existingEBook?.isFree ?? true;
    bool isFeatured = existingEBook?.isFeatured ?? false;

    PlatformFile? selectedCoverFile;
    PlatformFile? selectedPdfFile;
    bool isUploading = false;
    double uploadProgress = 0.0;

    final storageService = StorageService();

    // Auto-generate slug from title
    titleCtrl.addListener(() {
      if (!isEdit && slugCtrl.text.isEmpty) {
        final generated = titleCtrl.text.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
        slugCtrl.text = generated;
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

          return AlertDialog(
            backgroundColor: dialogBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(isEdit ? Icons.edit_note : Icons.picture_as_pdf, color: const Color(0xFF7C9CFF)),
                const SizedBox(width: 10),
                Text(
                  isEdit ? 'Edit eBook Details' : 'Upload New eBook',
                  style: const TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('BASIC INFORMATION', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF7C9CFF))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'eBook Title *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.book)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: slugCtrl,
                            decoration: const InputDecoration(labelText: 'URL Slug', border: OutlineInputBorder(), prefixIcon: Icon(Icons.link)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: authorCtrl,
                            decoration: const InputDecoration(labelText: 'Author Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Book Description / Overview', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description)),
                    ),
                    const SizedBox(height: 16),

                    const Text('MAPPING & CLASSIFICATION', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF7C9CFF))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: publication,
                            decoration: const InputDecoration(labelText: 'Publication', border: OutlineInputBorder()),
                            items: ['Oxford Educational Press', 'Aspire Books Company', 'NCERT Publications', 'Cambridge Press']
                                .map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (val) => setDlgState(() => publication = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: series,
                            decoration: const InputDecoration(labelText: 'Series', border: OutlineInputBorder()),
                            items: ['CBSE Standard 2026', 'ICSE Masterclass', 'State Board Series', 'Competitive Prep']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (val) => setDlgState(() => series = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: classId,
                            decoration: const InputDecoration(labelText: 'Class Level', border: OutlineInputBorder()),
                            items: ['Class 9', 'Class 10', 'Class 11', 'Class 12', 'General']
                                .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (val) => setDlgState(() => classId = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: subject,
                            decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                            items: ['Mathematics', 'Science', 'Physics', 'Chemistry', 'Biology', 'English', 'Social Studies']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (val) => setDlgState(() => subject = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text('PRICING & STATUS', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF7C9CFF))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Free eBook', style: TextStyle(fontSize: 13)),
                            subtitle: Text(isFree ? 'Accessible by all users' : 'Paid Premium content', style: const TextStyle(fontSize: 11)),
                            value: isFree,
                            onChanged: (val) => setDlgState(() => isFree = val),
                          ),
                        ),
                        Expanded(
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Featured Book', style: TextStyle(fontSize: 13)),
                            subtitle: const Text('Highlight on banner', style: TextStyle(fontSize: 11)),
                            value: isFeatured,
                            onChanged: (val) => setDlgState(() => isFeatured = val),
                          ),
                        ),
                      ],
                    ),
                    if (!isFree) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Price (₹)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.currency_rupee)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: discountCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Discount Price (₹)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.local_offer)),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<EBookAdminStatus>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Publication Status', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: EBookAdminStatus.published, child: Text('PUBLISHED (Visible publicly)')),
                        DropdownMenuItem(value: EBookAdminStatus.draft, child: Text('DRAFT (Admin working copy)')),
                        DropdownMenuItem(value: EBookAdminStatus.pending, child: Text('PENDING REVIEW')),
                        DropdownMenuItem(value: EBookAdminStatus.archived, child: Text('ARCHIVED (Hidden)')),
                      ],
                      onChanged: (val) => setDlgState(() => status = val!),
                    ),
                    const SizedBox(height: 16),

                    const Text('FILES & MEDIA ASSETS', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF7C9CFF))),
                    const SizedBox(height: 8),

                    // Cover Image Field
                    TextField(
                      controller: coverCtrl,
                      decoration: InputDecoration(
                        labelText: 'Book Cover Image URL',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.image),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.upload_file, color: Color(0xFF7C9CFF)),
                          tooltip: 'Upload Cover Image',
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(type: FileType.image);
                            if (result != null && result.files.isNotEmpty) {
                              setDlgState(() {
                                selectedCoverFile = result.files.first;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    if (selectedCoverFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('Selected Cover: ${selectedCoverFile!.name} (${(selectedCoverFile!.size / 1024).toStringAsFixed(1)} KB)', style: const TextStyle(fontSize: 11, color: Colors.green)),
                      ),
                    const SizedBox(height: 12),

                    // PDF Document File Field
                    TextField(
                      controller: fileCtrl,
                      decoration: InputDecoration(
                        labelText: 'PDF Document File URL *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.picture_as_pdf),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.cloud_upload, color: Color(0xFF7C9CFF)),
                          tooltip: 'Upload PDF Document',
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                            if (result != null && result.files.isNotEmpty) {
                              setDlgState(() {
                                selectedPdfFile = result.files.first;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    if (selectedPdfFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('Selected PDF: ${selectedPdfFile!.name} (${(selectedPdfFile!.size / 1024 / 1024).toStringAsFixed(2)} MB)', style: const TextStyle(fontSize: 11, color: Colors.green)),
                      ),
                    
                    if (isUploading) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: uploadProgress == 0.0 ? null : uploadProgress, color: const Color(0xFF7C9CFF)),
                      const SizedBox(height: 4),
                      const Text('Uploading assets to Supabase Storage...', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                    ],

                    const SizedBox(height: 16),
                    const Text('SEO OPTIMIZATION METADATA', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF7C9CFF))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: seoTitleCtrl,
                      decoration: const InputDecoration(labelText: 'SEO Title Tag', border: OutlineInputBorder(), prefixIcon: Icon(Icons.subtitles)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: seoKeywordsCtrl,
                      decoration: const InputDecoration(labelText: 'Keywords (Comma separated)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.tag)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: seoDescCtrl,
                      decoration: const InputDecoration(labelText: 'Meta Description', border: OutlineInputBorder(), prefixIcon: Icon(Icons.short_text)),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C9CFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.save),
                label: Text(isEdit ? 'Save Changes' : 'Upload eBook'),
                onPressed: isUploading
                    ? null
                    : () async {
                        if (titleCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter eBook title'), backgroundColor: Colors.red));
                          return;
                        }

                        setDlgState(() {
                          isUploading = true;
                        });

                        String finalCoverUrl = coverCtrl.text.trim();
                        String finalPdfUrl = fileCtrl.text.trim();

                        try {
                          // Handle Cover upload
                          if (selectedCoverFile != null) {
                            final uploadedCover = await storageService.uploadFile(
                              selectedCoverFile!,
                              bucketName: 'ebook_covers',
                            );
                            if (uploadedCover != null) finalCoverUrl = uploadedCover;
                          }

                          // Handle PDF upload
                          if (selectedPdfFile != null) {
                            final uploadedPdf = await storageService.uploadFile(
                              selectedPdfFile!,
                              bucketName: 'ebook_files',
                            );
                            if (uploadedPdf != null) finalPdfUrl = uploadedPdf;
                          }
                        } catch (e) {
                          debugPrint('Storage upload note: $e');
                        }

                        if (finalCoverUrl.isEmpty) {
                          finalCoverUrl = 'https://picsum.photos/300/400?seed=${titleCtrl.text.hashCode}';
                        }

                        final newEBook = EBookModel(
                          id: isEdit ? existingEBook.id : 'ebook_${DateTime.now().millisecondsSinceEpoch}',
                          title: titleCtrl.text.trim(),
                          slug: slugCtrl.text.trim(),
                          author: authorCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          publicationId: publication,
                          seriesId: series,
                          classId: classId,
                          subjectId: subject,
                          coverUrl: finalCoverUrl,
                          fileUrl: finalPdfUrl,
                          price: double.tryParse(priceCtrl.text.trim()) ?? 0.0,
                          discountPrice: double.tryParse(discountCtrl.text.trim()) ?? 0.0,
                          isFree: isFree,
                          isFeatured: isFeatured,
                          status: status,
                          seoTitle: seoTitleCtrl.text.trim(),
                          seoKeywords: seoKeywordsCtrl.text.trim(),
                          seoDescription: seoDescCtrl.text.trim(),
                        );

                        if (isEdit) {
                          await ref.read(ebookSubmissionsProvider.notifier).updateEBook(newEBook);
                        } else {
                          ref.read(ebookSubmissionsProvider.notifier).addEBookSubmission(newEBook, submittedBy: 'Admin', autoApprove: true);
                          await ref.read(ebookSubmissionsProvider.notifier).saveEBookToSupabase(
                                title: newEBook.title,
                                fileUrl: newEBook.fileUrl,
                                subjectName: newEBook.subjectId,
                              );
                        }

                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEdit ? 'eBook updated successfully' : 'eBook uploaded and published successfully'),
                              backgroundColor: const Color(0xFF4CD964),
                            ),
                          );
                        }
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  void _previewPdf(EBookModel ebook) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: 900,
          height: 700,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Scaffold(
              appBar: AppBar(
                title: Text('PDF Preview: ${ebook.title}', style: const TextStyle(fontFamily: 'Lexend', fontSize: 16)),
                backgroundColor: const Color(0xFF1E1E1E),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              body: PdfViewerScreen(ebook: ebook),
            ),
          ),
        ),
      ),
    );
  }

  void _deleteEBook(EBookModel ebook) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete', style: TextStyle(fontFamily: 'Lexend')),
        content: Text('Are you sure you want to permanently delete "${ebook.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(ebookSubmissionsProvider.notifier).deleteEBook(ebook.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('eBook deleted successfully'), backgroundColor: Color(0xFFFF6B6B)),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleBulkDelete() {
    if (_selectedEBookIds.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Bulk Delete'),
        content: Text('Are you sure you want to delete ${_selectedEBookIds.length} selected eBooks?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final ids = _selectedEBookIds.toList();
              await ref.read(ebookSubmissionsProvider.notifier).bulkDeleteEBooks(ids);
              setState(() {
                _selectedEBookIds.clear();
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${ids.length} eBooks deleted'), backgroundColor: const Color(0xFFFF6B6B)),
                );
              }
            },
            child: const Text('Delete All Selected'),
          ),
        ],
      ),
    );
  }

  void _handleBulkStatusChange(EBookAdminStatus status) async {
    if (_selectedEBookIds.isEmpty) return;
    final ids = _selectedEBookIds.toList();
    await ref.read(ebookSubmissionsProvider.notifier).bulkUpdateEBookStatus(ids, status);
    setState(() {
      _selectedEBookIds.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated status for ${ids.length} eBooks'), backgroundColor: const Color(0xFF4CD964)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissions = ref.watch(ebookSubmissionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // Filter Logic
    final filtered = submissions.where((item) {
      final ebook = item.ebook;
      final queryMatch = _searchQuery.isEmpty ||
          ebook.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ebook.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ebook.subjectId.toLowerCase().contains(_searchQuery.toLowerCase());

      final statusMatch = _statusFilter == 'ALL' || ebook.status.name.toUpperCase() == _statusFilter;

      bool pricingMatch = true;
      if (_pricingFilter == 'FREE') pricingMatch = ebook.isFree;
      if (_pricingFilter == 'PAID') pricingMatch = !ebook.isFree;

      final featuredMatch = !_featuredOnlyFilter || ebook.isFeatured;

      return queryMatch && statusMatch && pricingMatch && featuredMatch;
    }).toList();

    // Sort Logic
    if (_sortBy == 'NEWEST') {
      filtered.sort((a, b) => b.submittedDate.compareTo(a.submittedDate));
    } else if (_sortBy == 'TITLE') {
      filtered.sort((a, b) => a.ebook.title.compareTo(b.ebook.title));
    } else if (_sortBy == 'PRICE_HIGH') {
      filtered.sort((a, b) => b.ebook.price.compareTo(a.ebook.price));
    }

    // Pagination Logic
    final totalItems = filtered.length;
    final totalPages = (totalItems / _pageSize).ceil() == 0 ? 1 : (totalItems / _pageSize).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize) > totalItems ? totalItems : (startIndex + _pageSize);
    final paginatedItems = totalItems > 0 ? filtered.sublist(startIndex, endIndex) : <EBookSubmissionModel>[];

    // Dashboard Statistics
    final totalEBooks = submissions.length;
    final publishedCount = submissions.where((e) => e.ebook.status == EBookAdminStatus.published).length;
    final draftCount = submissions.where((e) => e.ebook.status == EBookAdminStatus.draft).length;
    final freeCount = submissions.where((e) => e.ebook.isFree).length;
    final paidCount = totalEBooks - freeCount;

    return BlurredDrawerScaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          'Admin eBook Management',
          style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Cloud Storage Sync',
            onPressed: () {
              ref.read(ebookSubmissionsProvider.notifier).fetchCloudEBooks();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Syncing eBooks from Supabase DB...')),
              );
            },
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C9CFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add eBook'),
              onPressed: () => _showAddEditEBookDialog(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentPath: '/admin/ebooks'),
      body: Container(
        color: bgColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPI Statistics Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 700;
                  final crossAxisCount = isMobile ? 2 : 5;

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: isMobile ? 1.6 : 2.2,
                    children: [
                      _buildKpiCard('Total eBooks', '$totalEBooks', Icons.book, const Color(0xFF7C9CFF), cardBg),
                      _buildKpiCard('Published', '$publishedCount', Icons.check_circle, const Color(0xFF4CD964), cardBg),
                      _buildKpiCard('Drafts', '$draftCount', Icons.edit_document, const Color(0xFFFFB84C), cardBg),
                      _buildKpiCard('Free Books', '$freeCount', Icons.card_giftcard, const Color(0xFF00C9FF), cardBg),
                      _buildKpiCard('Paid Books', '$paidCount', Icons.payments, const Color(0xFFE5484D), cardBg),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Filter Controls & Toolbar
              Card(
                color: cardBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search eBooks by title, author, or subject...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                isDense: true,
                              ),
                              onChanged: (val) => setState(() {
                                _searchQuery = val;
                                _currentPage = 1;
                              }),
                            ),
                          ),
                          const SizedBox(width: 12),
                          DropdownButton<String>(
                            value: _statusFilter,
                            items: const [
                              DropdownMenuItem(value: 'ALL', child: Text('Status: All')),
                              DropdownMenuItem(value: 'PUBLISHED', child: Text('Status: Published')),
                              DropdownMenuItem(value: 'DRAFT', child: Text('Status: Draft')),
                              DropdownMenuItem(value: 'ARCHIVED', child: Text('Status: Archived')),
                            ],
                            onChanged: (val) => setState(() {
                              _statusFilter = val!;
                              _currentPage = 1;
                            }),
                          ),
                          const SizedBox(width: 12),
                          DropdownButton<String>(
                            value: _pricingFilter,
                            items: const [
                              DropdownMenuItem(value: 'ALL', child: Text('Pricing: All')),
                              DropdownMenuItem(value: 'FREE', child: Text('Pricing: Free')),
                              DropdownMenuItem(value: 'PAID', child: Text('Pricing: Paid')),
                            ],
                            onChanged: (val) => setState(() {
                              _pricingFilter = val!;
                              _currentPage = 1;
                            }),
                          ),
                          const SizedBox(width: 12),
                          DropdownButton<String>(
                            value: _sortBy,
                            items: const [
                              DropdownMenuItem(value: 'NEWEST', child: Text('Sort: Newest')),
                              DropdownMenuItem(value: 'TITLE', child: Text('Sort: Title A-Z')),
                              DropdownMenuItem(value: 'PRICE_HIGH', child: Text('Sort: Price High-Low')),
                            ],
                            onChanged: (val) => setState(() => _sortBy = val!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          FilterChip(
                            label: const Text('Featured Only'),
                            selected: _featuredOnlyFilter,
                            selectedColor: const Color(0xFF7C9CFF).withOpacity(0.3),
                            onSelected: (val) => setState(() {
                              _featuredOnlyFilter = val;
                              _currentPage = 1;
                            }),
                          ),
                          const Spacer(),
                          if (_selectedEBookIds.isNotEmpty) ...[
                            Text('${_selectedEBookIds.length} Selected', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.publish, size: 16, color: Color(0xFF4CD964)),
                              label: const Text('Publish Selected'),
                              onPressed: () => _handleBulkStatusChange(EBookAdminStatus.published),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.drafts, size: 16, color: Color(0xFFFFB84C)),
                              label: const Text('Draft Selected'),
                              onPressed: () => _handleBulkStatusChange(EBookAdminStatus.draft),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B), foregroundColor: Colors.white),
                              icon: const Icon(Icons.delete, size: 16),
                              label: const Text('Delete Selected'),
                              onPressed: _handleBulkDelete,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Table / Content List Container
              Card(
                color: cardBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    if (paginatedItems.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(48),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.menu_book, size: 64, color: Colors.grey.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            const Text('No eBooks Found', style: TextStyle(fontFamily: 'Lexend', fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('Try adjusting your search query or upload a new eBook.', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 16,
                          headingRowHeight: 48,
                          dataRowMinHeight: 64,
                          dataRowMaxHeight: 64,
                          columns: [
                            DataColumn(
                              label: Checkbox(
                                value: _selectedEBookIds.length == paginatedItems.length && paginatedItems.isNotEmpty,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedEBookIds.addAll(paginatedItems.map((e) => e.ebook.id));
                                    } else {
                                      _selectedEBookIds.clear();
                                    }
                                  });
                                },
                              ),
                            ),
                            const DataColumn(label: Text('COVER', style: TextStyle(fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('EBOOK TITLE & AUTHOR', style: TextStyle(fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('SUBJECT / CLASS', style: TextStyle(fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('PRICING', style: TextStyle(fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('FEATURED', style: TextStyle(fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: paginatedItems.map((item) {
                            final ebook = item.ebook;
                            final isSelected = _selectedEBookIds.contains(ebook.id);

                            return DataRow(
                              selected: isSelected,
                              onSelectChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedEBookIds.add(ebook.id);
                                  } else {
                                    _selectedEBookIds.remove(ebook.id);
                                  }
                                });
                              },
                              cells: [
                                DataCell(
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedEBookIds.add(ebook.id);
                                        } else {
                                          _selectedEBookIds.remove(ebook.id);
                                        }
                                      });
                                    },
                                  ),
                                ),
                                DataCell(
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      ebook.coverUrl,
                                      width: 36,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 36,
                                        height: 48,
                                        color: Colors.grey.shade800,
                                        child: const Icon(Icons.book, size: 20, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 220,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ebook.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        Text(
                                          'By ${ebook.author}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ebook.subjectId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                      Text(ebook.classId, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  ebook.isFree
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFF4CD964).withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                                          child: const Text('FREE', style: TextStyle(color: Color(0xFF4CD964), fontSize: 11, fontWeight: FontWeight.bold)),
                                        )
                                      : Text('₹${ebook.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                DataCell(_buildStatusChip(ebook.status)),
                                DataCell(
                                  IconButton(
                                    icon: Icon(
                                      ebook.isFeatured ? Icons.star : Icons.star_border,
                                      color: ebook.isFeatured ? const Color(0xFFFFB84C) : Colors.grey,
                                    ),
                                    tooltip: ebook.isFeatured ? 'Featured' : 'Mark as Featured',
                                    onPressed: () {
                                      ref.read(ebookSubmissionsProvider.notifier).toggleEBookFeatured(ebook.id);
                                    },
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.picture_as_pdf, size: 18, color: Color(0xFF7C9CFF)),
                                        tooltip: 'Preview PDF',
                                        onPressed: () => _previewPdf(ebook),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 18, color: Colors.amber),
                                        tooltip: 'Edit eBook',
                                        onPressed: () => _showAddEditEBookDialog(ebook),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 18, color: Color(0xFFFF6B6B)),
                                        tooltip: 'Delete eBook',
                                        onPressed: () => _deleteEBook(ebook),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),

                    // Pagination Footer
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text('Showing ${startIndex + 1} to $endIndex of $totalItems eBooks', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const Spacer(),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                              ),
                              Text('Page $_currentPage of $totalPages', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color, Color bgColor) {
    return Card(
      color: bgColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(value, style: const TextStyle(fontFamily: 'Lexend', fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(EBookAdminStatus status) {
    Color bg;
    Color fg;
    String label = status.name.toUpperCase();

    switch (status) {
      case EBookAdminStatus.published:
        bg = const Color(0xFF4CD964).withOpacity(0.15);
        fg = const Color(0xFF4CD964);
        break;
      case EBookAdminStatus.draft:
        bg = const Color(0xFFFFB84C).withOpacity(0.15);
        fg = const Color(0xFFFFB84C);
        break;
      case EBookAdminStatus.pending:
        bg = const Color(0xFF7C9CFF).withOpacity(0.15);
        fg = const Color(0xFF7C9CFF);
        break;
      case EBookAdminStatus.archived:
      case EBookAdminStatus.rejected:
        bg = const Color(0xFFFF6B6B).withOpacity(0.15);
        fg = const Color(0xFFFF6B6B);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
