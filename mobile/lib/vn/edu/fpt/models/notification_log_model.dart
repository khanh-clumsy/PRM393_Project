class NotificationLogModel {
  final int notificationId;
  final int userId;
  final int? announcementId;
  final String title;
  final String body;
  final bool isRead;
  final String? readAt;
  final String createdAt;

  NotificationLogModel({
    required this.notificationId,
    required this.userId,
    this.announcementId,
    required this.title,
    required this.body,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  NotificationLogModel copyWith({
    bool? isRead,
    String? readAt,
  }) {
    return NotificationLogModel(
      notificationId: notificationId,
      userId: userId,
      announcementId: announcementId,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }

  factory NotificationLogModel.fromJson(Map<String, dynamic> json) {
    return NotificationLogModel(
      notificationId: json['notificationId'] as int,
      userId: json['userId'] as int,
      announcementId: json['announcementId'] as int?,
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['isRead'] as bool,
      readAt: json['readAt'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }
}
