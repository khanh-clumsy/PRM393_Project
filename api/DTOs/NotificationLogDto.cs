namespace PRM393API.DTOs;

public record NotificationLogDto(int NotificationId, int UserId, int? AnnouncementId, string Title, string Body, bool IsRead, DateTime? ReadAt, DateTime CreatedAt);
public record CreateNotificationLogDto(int UserId, int? AnnouncementId, string Title, string Body);
