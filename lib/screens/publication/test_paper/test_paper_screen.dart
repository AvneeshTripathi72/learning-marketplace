import 'package:flutter/material.dart';
import '../../../models/test_paper_model.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/hierarchy_picker.dart';
import 'test_paper_preview_screen.dart';

class TestPaperScreen extends StatefulWidget {
  const TestPaperScreen({super.key});

  @override
  State<TestPaperScreen> createState() => _TestPaperScreenState();
}

class _TestPaperScreenState extends State<TestPaperScreen> {
  String _selectedSeries = 'CBSE 2026';
  String _selectedClass = 'Class 10';
  String _selectedSubject = 'Mathematics';
  String _selectedPattern = 'Mid-Term Model Paper (80 Marks)';
  bool _includeAnswerKey = true;
  bool _isGenerating = false;

  final List<String> _patterns = [
    'Unit Test 1 (20 Marks)',
    'Unit Test 2 (20 Marks)',
    'Mid-Term Model Paper (80 Marks)',
    'Annual Pre-Board Model Exam (80 Marks)',
  ];

  void _generateTestPaper() async {
    setState(() => _isGenerating = true);

    await Future.delayed(const Duration(seconds: 1));

    final result = TestPaperResultModel(
      id: 'tp_${DateTime.now().millisecondsSinceEpoch}',
      title: '$_selectedSubject - $_selectedPattern',
      publicationName: 'Oxford Educational Press',
      testPdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      answerKeyPdfUrl: _includeAnswerKey
          ? 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf'
          : null,
      generatedDate: DateTime.now(),
    );

    if (mounted) {
      setState(() => _isGenerating = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TestPaperPreviewScreen(result: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Test Paper Generator'),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 16),
            const Text('Test Exam Blueprint Pattern', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedPattern,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _patterns.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => v != null ? setState(() => _selectedPattern = v) : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Include Answer Key & Solution Scheme'),
              subtitle: const Text('Generates separate answer scheme PDF tab'),
              value: _includeAnswerKey,
              onChanged: (val) => setState(() => _includeAnswerKey = val),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateTestPaper,
                icon: _isGenerating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.assignment),
                label: Text(_isGenerating ? 'Compiling Test Paper...' : 'Generate Model Test Paper'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
