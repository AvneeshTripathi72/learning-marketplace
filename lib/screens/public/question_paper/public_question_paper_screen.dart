import 'package:flutter/material.dart';
import '../../../models/question_paper_model.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/hierarchy_picker.dart';
import '../../publication/question_paper/question_paper_preview_screen.dart';

class PublicQuestionPaperScreen extends StatefulWidget {
  const PublicQuestionPaperScreen({super.key});

  @override
  State<PublicQuestionPaperScreen> createState() => _PublicQuestionPaperScreenState();
}

class _PublicQuestionPaperScreenState extends State<PublicQuestionPaperScreen> {
  String _selectedPublication = 'Oxford Educational Press';
  String _selectedSeries = 'CBSE 2026';
  String _selectedClass = 'Class 10';
  String _selectedSubject = 'Mathematics';
  double _totalMarks = 80;
  bool _isGenerating = false;

  final List<String> _publications = [
    'Oxford Educational Press',
    'Pearson India',
    'S. Chand Publishing',
  ];

  void _generatePaper() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 1));

    final result = QuestionPaperResultModel(
      id: 'qp_pub_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Public Model Paper - $_selectedSubject',
      publicationName: _selectedPublication,
      pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      generatedDate: DateTime.now(),
      series: _selectedSeries,
      className: _selectedClass,
      subject: _selectedSubject,
      totalMarks: _totalMarks.toInt(),
      timeMinutes: 180,
    );

    if (mounted) {
      setState(() => _isGenerating = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuestionPaperPreviewScreen(result: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Public Question Paper Generator'),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _selectedPublication,
              decoration: const InputDecoration(
                labelText: 'Select Publication Scope',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              items: _publications.map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => v != null ? setState(() => _selectedPublication = v) : null,
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            Text('Total Marks: ${_totalMarks.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _totalMarks,
              min: 20,
              max: 100,
              divisions: 8,
              label: '${_totalMarks.toInt()} Marks',
              onChanged: (v) => setState(() => _totalMarks = v),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generatePaper,
                icon: _isGenerating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.picture_as_pdf),
                label: Text(_isGenerating ? 'Compiling PDF...' : 'Generate Public Question Paper'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
