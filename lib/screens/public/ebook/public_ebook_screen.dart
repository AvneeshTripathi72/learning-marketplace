import 'package:flutter/material.dart';
import '../../../models/ebook_model.dart';
import '../../../widgets/hierarchy_picker.dart';
import '../../publication/ebook/pdf_viewer_screen.dart';

class PublicEbookScreen extends StatefulWidget {
  const PublicEbookScreen({super.key});

  @override
  State<PublicEbookScreen> createState() => _PublicEbookScreenState();
}

class _PublicEbookScreenState extends State<PublicEbookScreen> {
  String _selectedPublication = 'All Publications';
  String _selectedSeries = 'CBSE 2026';
  String _selectedClass = 'Class 10';
  String _selectedSubject = 'Mathematics';

  final List<String> _publications = [
    'All Publications',
    'Oxford Educational Press',
    'Pearson India',
    'S. Chand Publishing',
  ];

  final List<EBookModel> _ebooks = [
    EBookModel(
      id: 'pub_eb1',
      publicationId: 'oxford_pub',
      seriesId: 'cbse_2026',
      classId: 'class_10',
      subjectId: 'maths',
      title: 'Class 10 Mathematics Comprehensive Guide',
      coverUrl: 'https://via.placeholder.com/150',
      fileUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
    ),
    EBookModel(
      id: 'pub_eb2',
      publicationId: 'pearson_pub',
      seriesId: 'cbse_2026',
      classId: 'class_10',
      subjectId: 'science',
      title: 'Class 10 Physics & Chemistry Master Class',
      coverUrl: 'https://via.placeholder.com/150',
      fileUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Publications eBooks'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedPublication,
              decoration: const InputDecoration(
                labelText: 'Filter by Publication',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              items: _publications.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
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
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: _ebooks.length,
              itemBuilder: (context, index) {
                final ebook = _ebooks[index];
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
                            color: Colors.blueGrey[100],
                            child: const Center(child: Icon(Icons.picture_as_pdf, size: 48, color: Colors.red)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            ebook.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
