using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class NotificationLogRepository(Prm393dbContext db) : INotificationLogRepository
{
    public async Task<IEnumerable<NotificationLog>> GetByUserAsync(int userId) =>
        await db.NotificationLogs.Where(n => n.UserId == userId).OrderByDescending(n => n.CreatedAt).ToListAsync();

    public async Task<IEnumerable<NotificationLog>> GetUnreadByUserAsync(int userId) =>
        await db.NotificationLogs.Where(n => n.UserId == userId && !n.IsRead).ToListAsync();

    public async Task<int> CountUnreadAsync(int userId) =>
        await db.NotificationLogs.CountAsync(n => n.UserId == userId && !n.IsRead);

    public async Task<NotificationLog> CreateAsync(NotificationLog log)
    {
        db.NotificationLogs.Add(log);
        await db.SaveChangesAsync();
        return log;
    }

    public async Task<int> CreateManyAsync(IEnumerable<NotificationLog> logs)
    {
        var list = logs.ToList();
        if (list.Count == 0) return 0;

        db.NotificationLogs.AddRange(list);
        await db.SaveChangesAsync();
        return list.Count;
    }

    public async Task<NotificationLog?> MarkReadAsync(int id, int userId)
    {
        var existing = await db.NotificationLogs.FirstOrDefaultAsync(n => n.NotificationId == id && n.UserId == userId);
        if (existing is null) return null;

        existing.IsRead = true;
        existing.ReadAt = DateTime.UtcNow;
        await db.SaveChangesAsync();
        return existing;
    }

    public async Task<int> MarkAllReadAsync(int userId)
    {
        var unread = await db.NotificationLogs.Where(n => n.UserId == userId && !n.IsRead).ToListAsync();
        var now = DateTime.UtcNow;
        foreach (var log in unread)
        {
            log.IsRead = true;
            log.ReadAt = now;
        }

        await db.SaveChangesAsync();
        return unread.Count;
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
