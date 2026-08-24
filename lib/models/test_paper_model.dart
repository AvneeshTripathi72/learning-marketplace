class TestPaperConfigModel {
  final String seriesId;
  final String classId;
  final String subjectId;
  final String testPattern;
  final int durationMinutes;
  final bool includeAnswerKey;

  TestPaperConfigModel({
    required this.seriesId,
    required this.classId,
    required this.subjectId,
    required this.testPattern,
    required this.durationMinutes,
    required this.includeAnswerKey,
  });
}

class TestPaperResultModel {
  final String id;
  final String title;
  final String publicationName;
  final String testPdfUrl;
  final String? answerKeyPdfUrl;
  final DateTime generatedDate;

  TestPaperResultModel({
    required this.id,
    required this.title,
    required this.publicationName,
    required this.testPdfUrl,
    this.answerKeyPdfUrl,
    required this.generatedDate,
  });
}
