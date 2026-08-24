import 'package:flutter/material.dart';
import '../../../models/test_paper_model.dart';
import '../../publication/test_paper/test_paper_preview_screen.dart';

class PublicTestPaperScreen extends StatefulWidget {
  const PublicTestPaperScreen({super.key});

  @override
  State<PublicTestPaperScreen> createState() => _PublicTestPaperScreenState();
}

class _PublicTestPaperScreenState extends State<PublicTestPaperScreen> {
  String _selectedPattern = 'Mid-Term Model Paper';
  bool _includeAnswerKey = true;
  bool _isGenerating = false;

  void _generateTestPaper() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 1));

    final result = TestPaperResultModel(
      id: 'tp_pub_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Public Test Paper - $_selectedPattern',
      publicationName: 'All Publications Aggregate',
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
      appBar: AppBar(
        title: const Text('Public Test Paper Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Exam Blueprint Pattern', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPattern,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Mid-Term Model Paper', child: Text('Mid-Term Model Paper (80 Marks)')),
                DropdownMenuItem(value: 'Annual Model Exam', child: Text('Annual Model Exam (80 Marks)')),
              ],
              onChanged: (v) => v != null ? setState(() => _selectedPattern = v) : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Include Answer Key & Solution Scheme'),
              value: _includeAnswerKey,
              onChanged: (val) => setState(() => _includeAnswerKey = val),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateTestPaper,
                child: Text(_isGenerating ? 'Compiling...' : 'Generate Model Test Paper'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
