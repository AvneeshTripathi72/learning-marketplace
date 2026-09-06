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

enum EBookAdminStatus { published, draft, pending, archived, rejected }

class EBookModel {
  final String id;
  final String title;
  final String slug;
  final String author;
  final String description;
  final String publicationId;
  final String seriesId;
  final String classId;
  final String subjectId;
  final String coverUrl;
  final String fileUrl;
  final double price;
  final double discountPrice;
  final bool isFree;
  final bool isFeatured;
  final EBookAdminStatus status;
  bool isDownloaded;
  String? localPath;
  final String? seoTitle;
  final String? seoKeywords;
  final String? seoDescription;

  EBookModel({
    required this.id,
    required this.title,
    this.slug = '',
    this.author = 'Academic Editorial Board',
    this.description = '',
    required this.publicationId,
    required this.seriesId,
    required this.classId,
    required this.subjectId,
    required this.coverUrl,
    required this.fileUrl,
    this.price = 0.0,
    this.discountPrice = 0.0,
    this.isFree = true,
    this.isFeatured = false,
    this.status = EBookAdminStatus.published,
    this.isDownloaded = false,
    this.localPath,
    this.seoTitle,
    this.seoKeywords,
    this.seoDescription,
  });

  EBookModel copyWith({
    String? id,
    String? title,
    String? slug,
    String? author,
    String? description,
    String? publicationId,
    String? seriesId,
    String? classId,
    String? subjectId,
    String? coverUrl,
    String? fileUrl,
    double? price,
    double? discountPrice,
    bool? isFree,
    bool? isFeatured,
    EBookAdminStatus? status,
    bool? isDownloaded,
    String? localPath,
    String? seoTitle,
    String? seoKeywords,
    String? seoDescription,
  }) {
    return EBookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      author: author ?? this.author,
      description: description ?? this.description,
      publicationId: publicationId ?? this.publicationId,
      seriesId: seriesId ?? this.seriesId,
      classId: classId ?? this.classId,
      subjectId: subjectId ?? this.subjectId,
      coverUrl: coverUrl ?? this.coverUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      isFree: isFree ?? this.isFree,
      isFeatured: isFeatured ?? this.isFeatured,
      status: status ?? this.status,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
      seoTitle: seoTitle ?? this.seoTitle,
      seoKeywords: seoKeywords ?? this.seoKeywords,
      seoDescription: seoDescription ?? this.seoDescription,
    );
  }

  factory EBookModel.fromJson(Map<String, dynamic> json) {
    EBookAdminStatus eStatus = EBookAdminStatus.published;
    final statusStr = (json['status'] ?? '').toString().toUpperCase();
    if (statusStr == 'PENDING') eStatus = EBookAdminStatus.pending;
    if (statusStr == 'REJECTED') eStatus = EBookAdminStatus.rejected;
    if (statusStr == 'DRAFT') eStatus = EBookAdminStatus.draft;
    if (statusStr == 'ARCHIVED') eStatus = EBookAdminStatus.archived;

    return EBookModel(
      id: json['id'].toString(),
      title: json['title'] as String? ?? 'eBook Document',
      slug: json['slug'] as String? ?? '',
      author: json['author'] as String? ?? 'Academic Editorial Board',
      description: json['description'] as String? ?? '',
      publicationId: json['publicationId'] as String? ?? 'Oxford Educational Press',
      seriesId: json['seriesId'] as String? ?? 'CBSE 2026',
      classId: json['classId'] as String? ?? 'Class 10',
      subjectId: json['subjectId'] as String? ?? 'Mathematics',
      coverUrl: json['coverUrl'] as String? ?? 'https://picsum.photos/300/400',
      fileUrl: json['fileUrl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['discountPrice'] as num?)?.toDouble() ?? 0.0,
      isFree: json['isFree'] == true || (json['price'] as num?) == 0,
      isFeatured: json['isFeatured'] == true,
      status: eStatus,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      localPath: json['localPath'] as String?,
      seoTitle: json['seoTitle'] as String?,
      seoKeywords: json['seoKeywords'] as String?,
      seoDescription: json['seoDescription'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'author': author,
      'description': description,
      'publicationId': publicationId,
      'seriesId': seriesId,
      'classId': classId,
      'subjectId': subjectId,
      'coverUrl': coverUrl,
      'fileUrl': fileUrl,
      'price': price,
      'discountPrice': discountPrice,
      'isFree': isFree,
      'isFeatured': isFeatured,
      'status': status.name.toUpperCase(),
      'isDownloaded': isDownloaded,
      'localPath': localPath,
      'seoTitle': seoTitle,
      'seoKeywords': seoKeywords,
      'seoDescription': seoDescription,
    };
  }
}
