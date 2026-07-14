using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface INotificationLogService
{
    Task<IEnumerable<NotificationLogDto>> GetByUserAsync(int userId);
    Task<IEnumerable<NotificationLogDto>> GetUnreadByUserAsync(int userId);
    Task<int> CountUnreadAsync(int userId);
    Task<NotificationLogDto> CreateAsync(CreateNotificationLogDto dto);
    Task<NotificationLogDto?> MarkReadAsync(int id, int userId);
    Task<int> MarkAllReadAsync(int userId);
    Task<bool> DeleteAsync(int id);
}
