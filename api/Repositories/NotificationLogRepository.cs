using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class NotificationLogRepository(Prm393dbContext db) : INotificationLogRepository
{
    public async Task<IEnumerable<NotificationLog>> GetByUserAsync(int userId) =>
        await db.NotificationLogs.Where(n => n.UserId == userId).ToListAsync();

    public async Task<IEnumerable<NotificationLog>> GetUnreadByUserAsync(int userId) =>
        await db.NotificationLogs.Where(n => n.UserId == userId && !n.IsRead).ToListAsync();

    public async Task<NotificationLog> CreateAsync(NotificationLog log)
    {
        db.NotificationLogs.Add(log);
        await db.SaveChangesAsync();
        return log;
    }

    public async Task<NotificationLog?> MarkReadAsync(int id)
    {
        var existing = await db.NotificationLogs.FindAsync(id);
        if (existing is null) return null;

        existing.IsRead = true;
        existing.ReadAt = DateTime.UtcNow;
        await db.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var existing = await db.NotificationLogs.FindAsync(id);
        if (existing is null) return false;

        db.NotificationLogs.Remove(existing);
        await db.SaveChangesAsync();
        return true;
    }
}
