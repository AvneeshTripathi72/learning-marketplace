import '../models/question_paper_model.dart';

class PaperGeneratorService {
  Future<QuestionPaperResultModel> generateQuestionPaper(QuestionPaperConfigModel config) async {
    await Future.delayed(const Duration(seconds: 1));

    return QuestionPaperResultModel(
      id: 'qp_${DateTime.now().millisecondsSinceEpoch}',
      title: '${config.subjectId} - Model Question Paper (${config.totalMarks} Marks)',
      publicationName: 'Oxford Educational Press',
      pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      generatedDate: DateTime.now(),
    );
  }
}
