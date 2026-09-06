enum VideoPlatform { youtube, instagram, facebook, direct }
enum VideoStatus { pending, approved, rejected, inactive, deleted, draft, archived }

class VideoModel {
  final String id;
  final String title;
  final String slug;
  final String description;
  final String url;
  final VideoPlatform platform;
  final String channelName;
  final String category;
  final String subject;
  final String classId;
  final String publicationName;
  final String thumbnailUrl;
  final String bannerUrl;
  final String duration;
  final int viewsCount;
  final VideoStatus status;
  final bool isFeatured;
  final String submittedBy;
  final DateTime submittedDate;
  final String? seoTitle;
  final String? seoKeywords;
  final String? seoDescription;

  VideoModel({
    required this.id,
    required this.title,
    this.slug = '',
    this.description = '',
    required this.url,
    required this.platform,
    required this.channelName,
    required this.category,
    this.subject = 'General',
    this.classId = 'Class 10',
    this.publicationName = 'Oxford Educational Press',
    required this.thumbnailUrl,
    this.bannerUrl = '',
    required this.duration,
    required this.viewsCount,
    required this.status,
    this.isFeatured = false,
    required this.submittedBy,
    required this.submittedDate,
    this.seoTitle,
    this.seoKeywords,
    this.seoDescription,
  });

  VideoModel copyWith({
    String? id,
    String? title,
    String? slug,
    String? description,
    String? url,
    VideoPlatform? platform,
    String? channelName,
    String? category,
    String? subject,
    String? classId,
    String? publicationName,
    String? thumbnailUrl,
    String? bannerUrl,
    String? duration,
    int? viewsCount,
    VideoStatus? status,
    bool? isFeatured,
    String? submittedBy,
    DateTime? submittedDate,
    String? seoTitle,
    String? seoKeywords,
    String? seoDescription,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      url: url ?? this.url,
      platform: platform ?? this.platform,
      channelName: channelName ?? this.channelName,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      classId: classId ?? this.classId,
      publicationName: publicationName ?? this.publicationName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      duration: duration ?? this.duration,
      viewsCount: viewsCount ?? this.viewsCount,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedDate: submittedDate ?? this.submittedDate,
      seoTitle: seoTitle ?? this.seoTitle,
      seoKeywords: seoKeywords ?? this.seoKeywords,
      seoDescription: seoDescription ?? this.seoDescription,
    );
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    VideoStatus vStatus = VideoStatus.approved;
    final statusStr = (json['status'] ?? '').toString().toUpperCase();
    if (statusStr == 'PENDING') vStatus = VideoStatus.pending;
    if (statusStr == 'REJECTED') vStatus = VideoStatus.rejected;
    if (statusStr == 'DRAFT') vStatus = VideoStatus.draft;
    if (statusStr == 'ARCHIVED') vStatus = VideoStatus.archived;
    if (statusStr == 'INACTIVE') vStatus = VideoStatus.inactive;

    return VideoModel(
      id: json['id'].toString(),
      title: json['title'] as String? ?? json['channelName'] as String? ?? 'Untitled Video',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? '',
      platform: VideoPlatform.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['platform'] ?? 'youtube').toString().toLowerCase(),
        orElse: () => VideoPlatform.youtube,
      ),
      channelName: json['channelName'] as String? ?? 'Educational Channel',
      category: json['category'] as String? ?? 'Educational',
      subject: json['subject'] as String? ?? 'General',
      classId: json['classId'] as String? ?? 'Class 10',
      publicationName: json['publicationName'] as String? ?? 'Oxford Educational Press',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop',
      bannerUrl: json['bannerUrl'] as String? ?? '',
      duration: json['duration'] as String? ?? '15:00',
      viewsCount: json['viewsCount'] as int? ?? 0,
      status: vStatus,
      isFeatured: json['isFeatured'] == true,
      submittedBy: json['submittedBy'] as String? ?? 'Admin',
      submittedDate: json['submittedDate'] != null
          ? DateTime.parse(json['submittedDate'] as String)
          : DateTime.now(),
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
      'description': description,
      'url': url,
      'platform': platform.name,
      'channelName': channelName,
      'category': category,
      'subject': subject,
      'classId': classId,
      'publicationName': publicationName,
      'thumbnailUrl': thumbnailUrl,
      'bannerUrl': bannerUrl,
      'duration': duration,
      'viewsCount': viewsCount,
      'status': status.name.toUpperCase(),
      'isFeatured': isFeatured,
      'submittedBy': submittedBy,
      'submittedDate': submittedDate.toIso8601String(),
      'seoTitle': seoTitle,
      'seoKeywords': seoKeywords,
      'seoDescription': seoDescription,
    };
  }
}
