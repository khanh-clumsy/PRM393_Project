class AnnouncementModel {
  final int announcementId;
  final int authorId;
  final String title;
  final String content;
  final String announcementType;
  final String priority;
  final String createdAt;
  final List<int?> targetClassIds;
  final bool isRead;

  AnnouncementModel({
    required this.announcementId,
    required this.authorId,
    required this.title,
    required this.content,
    required this.announcementType,
    required this.priority,
    required this.createdAt,
    required this.targetClassIds,
    this.isRead = false,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      announcementId: json['announcementId'] as int,
      authorId: json['authorId'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      announcementType: json['announcementType'] as String,
      priority: json['priority'] as String,
      createdAt: json['createdAt'] as String,
      targetClassIds: (json['targetClassIds'] as List<dynamic>?)?.map((e) => e as int?).toList() ?? [],
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  AnnouncementModel copyWith({bool? isRead}) {
    return AnnouncementModel(
      announcementId: announcementId,
      authorId: authorId,
      title: title,
      content: content,
      announcementType: announcementType,
      priority: priority,
      createdAt: createdAt,
      targetClassIds: targetClassIds,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'announcementId': announcementId,
      'authorId': authorId,
      'title': title,
      'content': content,
      'announcementType': announcementType,
      'priority': priority,
      'createdAt': createdAt,
      'targetClassIds': targetClassIds,
      'isRead': isRead,
    };
  }
}
