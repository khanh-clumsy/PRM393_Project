namespace PRM393API.DTOs;

public record AnnouncementDto(
    int AnnouncementId,
    int AuthorId,
    string Title,
    string Content,
    string AnnouncementType,
    string Priority,
    DateTime CreatedAt,
    List<int?> TargetClassIds,
    bool IsRead = false);

public record CreateAnnouncementDto(int AuthorId, string Title, string Content, string AnnouncementType, string Priority, List<int?> TargetClassIds);
public record UpdateAnnouncementDto(string? Title, string? Content, string? Priority);
