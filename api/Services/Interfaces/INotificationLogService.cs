using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface INotificationLogService
{
    Task<IEnumerable<NotificationLogDto>> GetByUserAsync(int userId);
    Task<IEnumerable<NotificationLogDto>> GetUnreadByUserAsync(int userId);
    Task<NotificationLogDto> CreateAsync(CreateNotificationLogDto dto);
    Task<NotificationLogDto?> MarkReadAsync(int id);
    Task<bool> DeleteAsync(int id);
}
