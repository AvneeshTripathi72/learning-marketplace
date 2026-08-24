class SeriesModel {
  final String id;
  final String name;
  final String publicationId;
  final bool isPublic;

  SeriesModel({
    required this.id,
    required this.name,
    required this.publicationId,
    required this.isPublic,
  });
}

class ClassModel {
  final String id;
  final String name;
  final String seriesId;

  ClassModel({required this.id, required this.name, required this.seriesId});
}

class SubjectModel {
  final String id;
  final String name;
  final String classId;

  SubjectModel({required this.id, required this.name, required this.classId});
}

class EBookModel {
  final String id;
  final String title;
  final String publicationId;
  final String seriesId;
  final String classId;
  final String subjectId;
  final String coverUrl;
  final String fileUrl;
  bool isDownloaded;
  String? localPath;

  EBookModel({
    required this.id,
    required this.title,
    required this.publicationId,
    required this.seriesId,
    required this.classId,
    required this.subjectId,
    required this.coverUrl,
    required this.fileUrl,
    this.isDownloaded = false,
    this.localPath,
  });

  factory EBookModel.fromJson(Map<String, dynamic> json) {
    return EBookModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'eBook Document',
      publicationId: json['publicationId'] as String,
      seriesId: json['seriesId'] as String,
      classId: json['classId'] as String,
      subjectId: json['subjectId'] as String,
      coverUrl: json['coverUrl'] as String? ?? '',
      fileUrl: json['fileUrl'] as String,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      localPath: json['localPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'publicationId': publicationId,
      'seriesId': seriesId,
      'classId': classId,
      'subjectId': subjectId,
      'coverUrl': coverUrl,
      'fileUrl': fileUrl,
      'isDownloaded': isDownloaded,
      'localPath': localPath,
    };
  }
}
