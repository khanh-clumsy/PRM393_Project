using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class AnnouncementReadRepository(Prm393dbContext db) : IAnnouncementReadRepository
{
    public async Task<HashSet<int>> GetReadAnnouncementIdsAsync(int userId, IEnumerable<int> announcementIds)
    {
        var ids = announcementIds.Distinct().ToList();
        if (ids.Count == 0) return [];

        var read = await db.AnnouncementReads
            .AsNoTracking()
            .Where(r => r.UserId == userId && ids.Contains(r.AnnouncementId))
            .Select(r => r.AnnouncementId)
            .ToListAsync();
        return read.ToHashSet();
    }

    public async Task<bool> MarkReadAsync(int userId, int announcementId)
    {
        var exists = await db.AnnouncementReads
            .AnyAsync(r => r.UserId == userId && r.AnnouncementId == announcementId);
        if (exists) return true;

        var announcementExists = await db.Announcements
            .AnyAsync(a => a.AnnouncementId == announcementId);
        if (!announcementExists) return false;

        db.AnnouncementReads.Add(new AnnouncementRead
        {
            UserId = userId,
            AnnouncementId = announcementId,
            ReadAt = DateTime.UtcNow,
        });
        await db.SaveChangesAsync();
        return true;
    }

    public async Task<int> MarkAllReadAsync(int userId, IEnumerable<int> announcementIds)
    {
        var ids = announcementIds.Distinct().ToList();
        if (ids.Count == 0) return 0;

        var alreadyRead = await db.AnnouncementReads
            .Where(r => r.UserId == userId && ids.Contains(r.AnnouncementId))
            .Select(r => r.AnnouncementId)
            .ToListAsync();
        var already = alreadyRead.ToHashSet();
        var toInsert = ids.Where(id => !already.Contains(id)).ToList();
        if (toInsert.Count == 0) return 0;

        var now = DateTime.UtcNow;
        db.AnnouncementReads.AddRange(toInsert.Select(id => new AnnouncementRead
        {
            UserId = userId,
            AnnouncementId = id,
            ReadAt = now,
        }));
        await db.SaveChangesAsync();
        return toInsert.Count;
    }
}
