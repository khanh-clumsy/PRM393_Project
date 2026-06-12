using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class NotificationLogService(INotificationLogRepository repo) : INotificationLogService
{
    public async Task<IEnumerable<NotificationLogDto>> GetByUserAsync(int userId) =>
        (await repo.GetByUserAsync(userId)).Select(ToDto);

    public async Task<IEnumerable<NotificationLogDto>> GetUnreadByUserAsync(int userId) =>
        (await repo.GetUnreadByUserAsync(userId)).Select(ToDto);

    public async Task<NotificationLogDto> CreateAsync(CreateNotificationLogDto dto)
    {
        var entity = new NotificationLog
        {
            UserId = dto.UserId,
            AnnouncementId = dto.AnnouncementId,
            Title = dto.Title,
            Body = dto.Body,
            IsRead = false,
            CreatedAt = DateTime.UtcNow,
        };
        return ToDto(await repo.CreateAsync(entity));
    }

    public async Task<NotificationLogDto?> MarkReadAsync(int id)
    {
        var updated = await repo.MarkReadAsync(id);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) => await repo.DeleteAsync(id);

    private static NotificationLogDto ToDto(NotificationLog n) =>
        new(n.NotificationId, n.UserId, n.AnnouncementId, n.Title, n.Body, n.IsRead, n.ReadAt, n.CreatedAt);
}
