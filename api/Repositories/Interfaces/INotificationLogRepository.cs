using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface INotificationLogRepository
{
    Task<IEnumerable<NotificationLog>> GetByUserAsync(int userId);
    Task<IEnumerable<NotificationLog>> GetUnreadByUserAsync(int userId);
    Task<int> CountUnreadAsync(int userId);
    Task<NotificationLog> CreateAsync(NotificationLog log);
    Task<int> CreateManyAsync(IEnumerable<NotificationLog> logs);
    Task<NotificationLog?> MarkReadAsync(int id, int userId);
    Task<int> MarkAllReadAsync(int userId);
    Task<bool> DeleteAsync(int id);
}
