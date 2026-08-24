import 'package:flutter/material.dart';
import '../../../models/question_paper_model.dart';
import '../../../widgets/hierarchy_picker.dart';
import '../../../services/paper_generator_service.dart';
import 'question_paper_preview_screen.dart';

class QuestionPaperScreen extends StatefulWidget {
  const QuestionPaperScreen({super.key});

  @override
  State<QuestionPaperScreen> createState() => _QuestionPaperScreenState();
}

class _QuestionPaperScreenState extends State<QuestionPaperScreen> {
  String _selectedSeries = 'CBSE 2026';
  String _selectedClass = 'Class 10';
  String _selectedSubject = 'Mathematics';
  int _totalMarks = 80;
  int _timeMinutes = 180;
  bool _isGenerating = false;

  final List<String> _chapters = [
    'Chapter 1: Real Numbers',
    'Chapter 2: Polynomials',
    'Chapter 3: Pair of Linear Equations',
    'Chapter 4: Quadratic Equations',
    'Chapter 5: Arithmetic Progressions',
  ];
  final Set<String> _selectedChapterSet = {'Chapter 1: Real Numbers', 'Chapter 2: Polynomials'};

  void _generatePaper() async {
    setState(() => _isGenerating = true);

    final config = QuestionPaperConfigModel(
      seriesId: _selectedSeries,
      classId: _selectedClass,
      subjectId: _selectedSubject,
      selectedChapters: _selectedChapterSet.toList(),
      totalMarks: _totalMarks,
      timeMinutes: _timeMinutes,
      difficultyDistribution: {'Easy': 30, 'Medium': 50, 'Hard': 20},
    );

    final result = await PaperGeneratorService().generateQuestionPaper(config);

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
      appBar: AppBar(
        title: const Text('Question Paper Generator'),
      ),
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
            const Text('Select Chapters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ..._chapters.map(
              (ch) => CheckboxListTile(
                title: Text(ch),
                value: _selectedChapterSet.contains(ch),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedChapterSet.add(ch);
                    } else {
                      _selectedChapterSet.remove(ch);
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('Total Marks: $_totalMarks Marks', style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _totalMarks.toDouble(),
              min: 20,
              max: 100,
              divisions: 8,
              label: '$_totalMarks Marks',
              onChanged: (v) => setState(() => _totalMarks = v.toInt()),
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
                label: Text(_isGenerating ? 'Generating Paper...' : 'Generate Question Paper PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
