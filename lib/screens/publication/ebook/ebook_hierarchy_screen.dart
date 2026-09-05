import 'package:flutter/material.dart';
import '../../../models/ebook_model.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/hierarchy_picker.dart';
import '../../shared/magazine/magazine_screen.dart';
import 'pdf_viewer_screen.dart';

class EBookHierarchyScreen extends StatefulWidget {
  const EBookHierarchyScreen({super.key});

  @override
  State<EBookHierarchyScreen> createState() => _EBookHierarchyScreenState();
}

class _EBookHierarchyScreenState extends State<EBookHierarchyScreen> {
  int _activeTabIndex = 0;
  String _selectedSeries = 'CBSE 2026';
  String _selectedClass = 'Class 10';
  String _selectedSubject = 'Mathematics';

  final List<EBookModel> _mockEBooks = [
    EBookModel(
      id: 'eb_101',
      title: 'Class 10 Mathematics - Chapter 1 Real Numbers',
      publicationId: 'oxford_pub',
      seriesId: 'CBSE 2026',
      classId: 'Class 10',
      subjectId: 'Mathematics',
      coverUrl: 'https://via.placeholder.com/150x200',
      fileUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
    ),
    EBookModel(
      id: 'eb_102',
      title: 'Class 10 Mathematics - Chapter 2 Polynomials',
      publicationId: 'oxford_pub',
      seriesId: 'CBSE 2026',
      classId: 'Class 10',
      subjectId: 'Mathematics',
      coverUrl: 'https://via.placeholder.com/150x200',
      fileUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(_activeTabIndex == 0 ? 'eBook Library' : 'Educational Magazines'),
        actions: [
          if (_activeTabIndex == 0)
            IconButton(
              icon: const Icon(Icons.cloud_upload_outlined),
              tooltip: 'Upload Vendor eBook',
              onPressed: () => _showVendorUploadEBookDialog(context),
            ),
        ],
      ),
      floatingActionButton: _activeTabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showVendorUploadEBookDialog(context),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload eBook'),
            )
          : null,
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
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _mockEBooks.length,
                          itemBuilder: (context, index) {
                            final ebook = _mockEBooks[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
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
                                        color: Colors.grey[800],
                                        child: const Center(
                                          child: Icon(Icons.picture_as_pdf, size: 50, color: Colors.redAccent),
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
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                ebook.isDownloaded ? Icons.download_done : Icons.cloud_download,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                ebook.isDownloaded ? 'Downloaded' : 'Online',
                                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                              ),
                                            ],
                                          ),
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
                    ],
                  )
                : const MagazineViewBody(),
          ),
        ],
      ),
    );
  }

  void _showVendorUploadEBookDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final pdfUrlCtrl = TextEditingController(text: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf');
    String series = _selectedSeries;
    String cls = _selectedClass;
    String subject = _selectedSubject;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.library_add, color: Colors.blue),
              SizedBox(width: 10),
              Text('Vendor eBook Upload', style: TextStyle(fontSize: 16)),
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
                  decoration: const InputDecoration(
                    labelText: 'PDF Document Link / URL',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.picture_as_pdf),
                  ),
                ),
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
              label: const Text('Publish eBook'),
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter eBook title')),
                  );
                  return;
                }
                setState(() {
                  _mockEBooks.insert(
                    0,
                    EBookModel(
                      id: 'eb_vendor_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleCtrl.text.trim(),
                      publicationId: 'vendor_pub',
                      seriesId: series,
                      classId: cls,
                      subjectId: subject,
                      coverUrl: 'https://via.placeholder.com/150x200',
                      fileUrl: pdfUrlCtrl.text.trim().isEmpty
                          ? 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf'
                          : pdfUrlCtrl.text.trim(),
                    ),
                  );
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('eBook "${titleCtrl.text.trim()}" published successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
