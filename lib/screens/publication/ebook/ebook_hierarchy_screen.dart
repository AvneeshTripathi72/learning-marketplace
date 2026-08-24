import 'package:flutter/material.dart';
import '../../../models/ebook_model.dart';
import '../../../widgets/hierarchy_picker.dart';
import 'pdf_viewer_screen.dart';

class EBookHierarchyScreen extends StatefulWidget {
  const EBookHierarchyScreen({super.key});

  @override
  State<EBookHierarchyScreen> createState() => _EBookHierarchyScreenState();
}

class _EBookHierarchyScreenState extends State<EBookHierarchyScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('eBook Library'),
      ),
      body: Column(
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
      ),
    );
  }
}
