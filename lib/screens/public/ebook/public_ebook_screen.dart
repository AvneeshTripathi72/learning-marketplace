import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/ebook_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/ebook_provider.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/hierarchy_picker.dart';
import '../../../widgets/core/debounced_search_bar.dart';
import '../../../widgets/core/empty_state_view.dart';
import '../../publication/ebook/pdf_viewer_screen.dart';
import '../../shared/magazine/magazine_screen.dart';
import '../../../widgets/core/blurred_drawer_scaffold.dart';

class PublicEbookScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const PublicEbookScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<PublicEbookScreen> createState() => _PublicEbookScreenState();
}

class _PublicEbookScreenState extends ConsumerState<PublicEbookScreen> {
  late int _activeTabIndex;

  String _selectedPublication = 'All Publications';
  String _selectedSeries = 'CBSE 2026';
  String _selectedClass = 'Class 10';
  String _selectedSubject = 'Mathematics';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTabIndex;
  }

  final List<String> _publications = [
    'All Publications',
    'Oxford Educational Press',
    'Pearson India',
    'S. Chand Publishing',
  ];

  void _showUploadPdfModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final pdfUrlCtrl = TextEditingController();
    String series = _selectedSeries;
    String cls = _selectedClass;
    String subject = _selectedSubject;
    PlatformFile? selectedPdfFile;
    bool isUploading = false;
    double uploadProgress = 0.0;

    final storageService = StorageService();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
          final dialogBg = isDarkTheme ? const Color(0xFF1E1E1E) : Colors.white;
          final inputBg = isDarkTheme ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F7);
          final accentCol = isDarkTheme ? const Color(0xFF7C9CFF) : const Color(0xFF4A6CF7);

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: dialogBg,
            title: Row(
              children: [
                Icon(Icons.picture_as_pdf_rounded, color: accentCol),
                const SizedBox(width: 10),
                const Text(
                  'Upload eBook PDF',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'eBook Title',
                      hintText: 'e.g. Class 10 Maths Chapter 3',
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.book_rounded, color: accentCol),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: series,
                    decoration: const InputDecoration(labelText: 'Series', border: OutlineInputBorder()),
                    items: ['CBSE 2026', 'ICSE 2026', 'State Board']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => val != null ? setDialogState(() => series = val) : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: cls,
                    decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
                    items: ['Class 9', 'Class 10', 'Class 11', 'Class 12']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => val != null ? setDialogState(() => cls = val) : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: subject,
                    decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                    items: ['Mathematics', 'Science', 'English', 'Hindi']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => val != null ? setDialogState(() => subject = val) : null,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pdfUrlCtrl,
                    enabled: selectedPdfFile == null,
                    decoration: const InputDecoration(
                      labelText: 'PDF Document Link / URL',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.picture_as_pdf),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(child: Text("OR", style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: isUploading ? null : () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                        withData: true,
                      );
                      if (result != null && result.files.isNotEmpty) {
                        setDialogState(() {
                          selectedPdfFile = result.files.first;
                          pdfUrlCtrl.text = '';
                        });
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(selectedPdfFile != null ? 'Selected: ${selectedPdfFile!.name}' : 'Select PDF File'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  if (selectedPdfFile != null)
                    TextButton(
                      onPressed: () => setDialogState(() => selectedPdfFile = null),
                      child: const Text('Remove File', style: TextStyle(color: Colors.red)),
                    ),
                  if (isUploading && selectedPdfFile != null) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: uploadProgress),
                    const SizedBox(height: 8),
                    Text('${(uploadProgress * 100).toStringAsFixed(0)}% Uploaded', textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Submit eBook'),
                onPressed: isUploading ? null : () async {
                  if (titleCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter eBook title')),
                    );
                    return;
                  }
                  if (pdfUrlCtrl.text.trim().isEmpty && selectedPdfFile == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter eBook URL or select a PDF file')),
                    );
                    return;
                  }

                  setDialogState(() {
                    isUploading = true;
                    uploadProgress = 0.0;
                  });

                  String finalUrl = pdfUrlCtrl.text.trim();
                  if (selectedPdfFile != null) {
                    finalUrl = await storageService.uploadPDF(selectedPdfFile!, onProgress: (progress) {
                      setDialogState(() {
                        uploadProgress = progress;
                      });
                    }) ?? '';
                  }

                  if (finalUrl.isEmpty) {
                    setDialogState(() => isUploading = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to upload PDF file.')),
                      );
                    }
                    return;
                  }

                  final newEBook = EBookModel(
                    id: 'eb_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleCtrl.text.trim(),
                    publicationId: 'Public Upload',
                    seriesId: series,
                    classId: cls,
                    subjectId: subject,
                    coverUrl: 'https://picsum.photos/300/400?random=${DateTime.now().millisecondsSinceEpoch % 1000}',
                    fileUrl: finalUrl,
                  );

                  ref.read(ebookSubmissionsProvider.notifier).addEBookSubmission(
                    newEBook,
                    submittedBy: 'Public User',
                    autoApprove: true,
                  );

                  await ref.read(ebookSubmissionsProvider.notifier).saveEBookToSupabase(
                    title: newEBook.title,
                    fileUrl: finalUrl,
                    subjectName: subject,
                  );

                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('eBook PDF uploaded & added to library!')),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7);
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final elevatedColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F3);
    final accentPrimary = isDark ? const Color(0xFF7C9CFF) : const Color(0xFF4A6CF7);

    final currentUser = ref.watch(authProvider);
    final isPublisherOrAdmin = currentUser != null &&
        (currentUser.role == UserRole.publication || currentUser.role == UserRole.admin);

    final allSubmissions = ref.watch(ebookSubmissionsProvider);
    final approvedSubmissions = allSubmissions.where((item) => item.status == EBookStatus.approved).toList();

    final filteredEbooks = approvedSubmissions.where((item) {
      final ebook = item.ebook;
      final matchesPub = _selectedPublication == 'All Publications' ||
          ebook.publicationId.toLowerCase().contains(_selectedPublication.toLowerCase());
      final matchesSeries = ebook.seriesId.isEmpty ||
          ebook.seriesId.toLowerCase().contains(_selectedSeries.toLowerCase()) ||
          _selectedSeries.toLowerCase().contains(ebook.seriesId.toLowerCase());
      final matchesClass = ebook.classId.isEmpty ||
          ebook.classId.toLowerCase().contains(_selectedClass.toLowerCase()) ||
          _selectedClass.toLowerCase().contains(ebook.classId.toLowerCase());
      final matchesSubject = ebook.subjectId.isEmpty ||
          ebook.subjectId.toLowerCase().contains(_selectedSubject.toLowerCase()) ||
          _selectedSubject.toLowerCase().contains(ebook.subjectId.toLowerCase());
      final matchesSearch = _searchQuery.isEmpty || 
          ebook.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ebook.subjectId.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesPub && (matchesSeries || matchesClass || matchesSubject) && matchesSearch;
    }).map((item) => item.ebook).toList();

    final availablePubs = <String>{'All Publications'};
    for (final sub in approvedSubmissions) {
      if (sub.ebook.publicationId.isNotEmpty) {
        availablePubs.add(sub.ebook.publicationId);
      }
    }
    final publicationsList = availablePubs.toList();
    final currentPubValue = publicationsList.contains(_selectedPublication) ? _selectedPublication : 'All Publications';

    return BlurredDrawerScaffold(
      extendBody: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          _activeTabIndex == 0 ? 'Publication eBooks' : 'Educational Magazines',
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: isPublisherOrAdmin
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [accentPrimary, accentPrimary.withOpacity(0.8)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentPrimary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _showUploadPdfModal(context),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.picture_as_pdf, size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Upload PDF',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            : [],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
      body: Container(
        color: bgColor,
        child: Column(
          children: [
            // Premium Segmented Tab Bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: elevatedColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _activeTabIndex == 0 ? accentPrimary : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: _activeTabIndex == 0
                              ? [
                                  BoxShadow(
                                    color: accentPrimary.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 18,
                              color: _activeTabIndex == 0 ? Colors.white : (isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'eBooks Library',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: _activeTabIndex == 0 ? Colors.white : (isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTabIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _activeTabIndex == 1 ? accentPrimary : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: _activeTabIndex == 1
                              ? [
                                  BoxShadow(
                                    color: accentPrimary.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_stories_rounded,
                              size: 18,
                              color: _activeTabIndex == 1 ? Colors.white : (isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Magazines Hub',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: _activeTabIndex == 1 ? Colors.white : (isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Content Body
            Expanded(
              child: _activeTabIndex == 0
                  ? Column(
                      children: [
                        // Search & Filter Panel
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              DebouncedSearchBar(
                                hintText: 'Search eBooks by title or topic...',
                                onChanged: (val) => setState(() => _searchQuery = val),
                              ),
                              const SizedBox(height: 10),
                               DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: currentPubValue,
                                dropdownColor: surfaceColor,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A),
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Filter by Publisher',
                                  labelStyle: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B),
                                  ),
                                  filled: true,
                                  fillColor: elevatedColor,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(Icons.business_rounded, color: accentPrimary, size: 18),
                                ),
                                items: publicationsList
                                    .map((p) => DropdownMenuItem(
                                          value: p,
                                          child: Text(p, overflow: TextOverflow.ellipsis),
                                        ))
                                    .toList(),
                                onChanged: (v) => v != null ? setState(() => _selectedPublication = v) : null,
                              ),
                            ],
                          ),
                        ),

                        // Hierarchy Selector
                        HierarchyPicker(
                          seriesList: const ['CBSE 2026', 'ICSE 2026', 'State Board'],
                          classList: const ['Class 9', 'Class 10', 'Class 11', 'Class 12'],
                          subjectList: const ['Mathematics', 'Science', 'English', 'Hindi'],
                          selectedSeries: _selectedSeries,
                          selectedClass: _selectedClass,
                          selectedSubject: _selectedSubject,
                          onSeriesChanged: (v) => setState(() => _selectedSeries = v),
                          onClassChanged: (v) => setState(() => _selectedClass = v),
                          onSubjectChanged: (v) => setState(() => _selectedSubject = v),
                        ),

                        // eBooks Grid or Empty State
                        Expanded(
                          child: filteredEbooks.isEmpty
                              ? EmptyStateView(
                                  icon: Icons.picture_as_pdf_rounded,
                                  title: 'No eBooks found for $_selectedClass - $_selectedSubject',
                                  message: isPublisherOrAdmin
                                      ? 'Tap "Upload eBook PDF" to publish new learning material or PDF document link to this catalog.'
                                      : 'No eBook learning materials available for $_selectedClass - $_selectedSubject yet.',
                                  actionText: isPublisherOrAdmin ? 'Upload eBook PDF' : null,
                                  onAction: isPublisherOrAdmin ? () => _showUploadPdfModal(context) : null,
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.65,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                  ),
                                  itemCount: filteredEbooks.length,
                                  itemBuilder: (context, index) {
                                    final ebook = filteredEbooks[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: surfaceColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                                          width: 1,
                                        ),
                                        boxShadow: isDark
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.04),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                )
                                              ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(12),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => PdfViewerScreen(ebook: ebook),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Cover Image Thumbnail with PDF Badge
                                              Expanded(
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                                                        image: DecorationImage(
                                                          image: NetworkImage(ebook.coverUrl),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 8,
                                                      right: 8,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: Colors.redAccent.withOpacity(0.9),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(Icons.picture_as_pdf, size: 10, color: Colors.white),
                                                            SizedBox(width: 3),
                                                            Text(
                                                              'PDF',
                                                              style: TextStyle(
                                                                fontFamily: 'Inter',
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 9,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // eBook Meta Description
                                              Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      ebook.title,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontFamily: 'Lexend',
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: accentPrimary.withOpacity(0.15),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: Text(
                                                            ebook.subjectId.isEmpty ? 'Maths' : ebook.subjectId,
                                                            style: TextStyle(
                                                              fontFamily: 'Inter',
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.w500,
                                                              color: accentPrimary,
                                                            ),
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    )
                  : const MagazineScreen(),
            ),
          ],
        ),
      ),
    );
  }

}
