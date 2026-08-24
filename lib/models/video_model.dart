enum VideoPlatform { youtube, instagram, facebook }
enum VideoStatus { pending, approved, rejected, inactive, deleted }

class VideoModel {
  final String id;
  final String title;
  final String url;
  final VideoPlatform platform;
  final String channelName;
  final String category;
  final String thumbnailUrl;
  final String duration;
  final int viewsCount;
  final VideoStatus status;
  final String submittedBy;
  final DateTime submittedDate;

  VideoModel({
    required this.id,
    required this.title,
    required this.url,
    required this.platform,
    required this.channelName,
    required this.category,
    required this.thumbnailUrl,
    required this.duration,
    required this.viewsCount,
    required this.status,
    required this.submittedBy,
    required this.submittedDate,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled Video',
      url: json['url'] as String,
      platform: VideoPlatform.values.firstWhere(
        (e) => e.name == json['platform'],
        orElse: () => VideoPlatform.youtube,
      ),
      channelName: json['channelName'] as String? ?? 'Unknown Channel',
      category: json['category'] as String? ?? 'General',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      duration: json['duration'] as String? ?? '0:00',
      viewsCount: json['viewsCount'] as int? ?? 0,
      status: VideoStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VideoStatus.approved,
      ),
      submittedBy: json['submittedBy'] as String? ?? 'System',
      submittedDate: json['submittedDate'] != null
          ? DateTime.parse(json['submittedDate'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'platform': platform.name,
      'channelName': channelName,
      'category': category,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'viewsCount': viewsCount,
      'status': status.name,
      'submittedBy': submittedBy,
      'submittedDate': submittedDate.toIso8601String(),
    };
  }
}
