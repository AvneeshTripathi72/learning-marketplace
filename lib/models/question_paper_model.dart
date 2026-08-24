class QuestionPaperConfigModel {
  final String seriesId;
  final String classId;
  final String subjectId;
  final List<String> selectedChapters;
  final int totalMarks;
  final int timeMinutes;
  final Map<String, int> difficultyDistribution;

  QuestionPaperConfigModel({
    required this.seriesId,
    required this.classId,
    required this.subjectId,
    required this.selectedChapters,
    required this.totalMarks,
    required this.timeMinutes,
    required this.difficultyDistribution,
  });
}

class QuestionPaperResultModel {
  final String id;
  final String title;
  final String publicationName;
  final String pdfUrl;
  final DateTime generatedDate;

  QuestionPaperResultModel({
    required this.id,
    required this.title,
    required this.publicationName,
    required this.pdfUrl,
    required this.generatedDate,
  });
}
