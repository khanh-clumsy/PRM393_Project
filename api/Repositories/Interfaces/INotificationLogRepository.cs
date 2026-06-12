using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface INotificationLogRepository
{
    Task<IEnumerable<NotificationLog>> GetByUserAsync(int userId);
    Task<IEnumerable<NotificationLog>> GetUnreadByUserAsync(int userId);
    Task<NotificationLog> CreateAsync(NotificationLog log);
    Task<NotificationLog?> MarkReadAsync(int id);
    Task<bool> DeleteAsync(int id);
}
