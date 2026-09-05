class MagazineModel {
  final String id;
  final String title;
  final String description;
  final String coverImageUrl;
  final String pdfUrl;
  final String publicationId;
  final String publicationName;
  final String category;
  final DateTime issueDate;
  final int downloadCount;

  MagazineModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.pdfUrl,
    required this.publicationId,
    required this.publicationName,
    required this.category,
    required this.issueDate,
    this.downloadCount = 0,
  });

  factory MagazineModel.fromJson(Map<String, dynamic> json) {
    return MagazineModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled Magazine',
      description: json['description'] as String? ?? '',
      coverImageUrl: json['coverImageUrl'] as String? ?? '',
      pdfUrl: json['pdfUrl'] as String? ?? '',
      publicationId: json['publicationId'] as String? ?? 'general',
      publicationName: json['publicationName'] as String? ?? 'General Publisher',
      category: json['category'] as String? ?? 'General',
      issueDate: json['issueDate'] != null
          ? DateTime.parse(json['issueDate'] as String)
          : DateTime.now(),
      downloadCount: json['downloadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'pdfUrl': pdfUrl,
      'publicationId': publicationId,
      'publicationName': publicationName,
      'category': category,
      'issueDate': issueDate.toIso8601String(),
      'downloadCount': downloadCount,
    };
  }
}
