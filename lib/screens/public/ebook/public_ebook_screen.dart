import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/ebook_model.dart';
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
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.library_add, color: Colors.blue),
                SizedBox(width: 10),
                Text('eBook Document Upload', style: TextStyle(fontSize: 16)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'eBook Title',
                      hintText: 'e.g. Class 10 Maths Chapter 3',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book),
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

    final allSubmissions = ref.watch(ebookSubmissionsProvider);
    final approvedSubmissions = allSubmissions.where((item) => item.status == EBookStatus.approved).toList();

    final filteredEbooks = approvedSubmissions.where((item) {
      final ebook = item.ebook;
      final matchesPub = _selectedPublication == 'All Publications' ||
          ebook.publicationId.toLowerCase().contains(_selectedPublication.toLowerCase());
      final matchesSeries = ebook.seriesId.isEmpty || ebook.seriesId.toLowerCase() == _selectedSeries.toLowerCase();
      final matchesClass = ebook.classId.isEmpty || ebook.classId.toLowerCase() == _selectedClass.toLowerCase();
      final matchesSubject = ebook.subjectId.isEmpty || ebook.subjectId.toLowerCase() == _selectedSubject.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty || 
          ebook.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesPub && matchesSeries && matchesClass && matchesSubject && matchesSearch;
    }).map((item) => item.ebook).toList();

    return BlurredDrawerScaffold(
      extendBody: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(_activeTabIndex == 0 ? 'All Publications eBooks' : 'Educational Magazines'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text('Upload PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () => _showUploadPdfModal(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
      body: Column(
        children: [
          // Segmented Tab Toggle Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _activeTabIndex == 0 ? theme.colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book,
                            size: 18,
                            color: _activeTabIndex == 0 ? Colors.white : theme.textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'eBooks',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _activeTabIndex == 0 ? Colors.white : theme.textTheme.bodyMedium?.color,
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
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _activeTabIndex == 1 ? theme.colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_stories,
                            size: 18,
                            color: _activeTabIndex == 1 ? Colors.white : theme.textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Magazines',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _activeTabIndex == 1 ? Colors.white : theme.textTheme.bodyMedium?.color,
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

          // Tab Body Content
          Expanded(
            child: _activeTabIndex == 0
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: DebouncedSearchBar(
                          hintText: 'Search eBooks by title...',
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _selectedPublication,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Publication',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.business),
                          ),
                          items: _publications
                              .map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (v) => v != null ? setState(() => _selectedPublication = v) : null,
                        ),
                      ),
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
                      Expanded(
                        child: filteredEbooks.isEmpty
                            ? EmptyStateView(
                                icon: Icons.menu_book_outlined,
                                title: 'No verified eBooks found in "$_selectedClass - $_selectedSubject"',
                                message: 'Change filter selections above to explore available textbooks.',
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.68,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: filteredEbooks.length,
                                itemBuilder: (context, index) {
                                  final ebook = filteredEbooks[index];
                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                                image: DecorationImage(
                                                  image: NetworkImage(ebook.coverUrl),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ebook.title,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${ebook.seriesId} • ${ebook.classId}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: theme.textTheme.bodySmall?.color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
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
    );
  }
}
