using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class AnnouncementRepository(Prm393dbContext db) : IAnnouncementRepository
{
    public async Task<IEnumerable<Announcement>> GetAllAsync() =>
        await db.Announcements
            .Include(a => a.AnnouncementTargets)
            .Where(a => !a.IsDeleted)
            .ToListAsync();

    public async Task<Announcement?> GetByIdAsync(int id) =>
        await db.Announcements
            .Include(a => a.AnnouncementTargets)
            .FirstOrDefaultAsync(a => a.AnnouncementId == id && !a.IsDeleted);

    public async Task<IEnumerable<Announcement>> GetByClassAsync(int classId) =>
        await db.Announcements
            .Include(a => a.AnnouncementTargets)
            .Where(a => !a.IsDeleted &&
                        a.AnnouncementTargets.Any(t => t.ClassId == classId || t.ClassId == null))
            .OrderByDescending(a => a.CreatedAt)
            .ToListAsync();

    public async Task<IEnumerable<Announcement>> GetFeedByClassIdsAsync(IEnumerable<int> classIds, bool includeAll)
    {
        var ids = classIds.Distinct().ToList();
        var query = db.Announcements
            .Include(a => a.AnnouncementTargets)
            .Where(a => !a.IsDeleted);

        if (!includeAll)
        {
            query = query.Where(a => a.AnnouncementTargets.Any(t =>
                t.ClassId == null || (t.ClassId.HasValue && ids.Contains(t.ClassId.Value))));
        }

        return await query.OrderByDescending(a => a.CreatedAt).ToListAsync();
    }

    public async Task<Announcement> CreateAsync(Announcement announcement, List<int?> targetClassIds)
    {
        db.Announcements.Add(announcement);
        await db.SaveChangesAsync();

        var targets = targetClassIds.Select(classId => new AnnouncementTarget
        {
            AnnouncementId = announcement.AnnouncementId,
            ClassId = classId,
        }).ToList();
        db.AnnouncementTargets.AddRange(targets);
        await db.SaveChangesAsync();

        announcement.AnnouncementTargets = targets;
        return announcement;
    }

    public async Task<Announcement?> UpdateAsync(int id, Announcement updated)
    {
        var existing = await db.Announcements.FindAsync(id);
        if (existing is null || existing.IsDeleted) return null;

        existing.Title = updated.Title;
        existing.Content = updated.Content;
        existing.Priority = updated.Priority;
        existing.UpdatedAt = updated.UpdatedAt;
        await db.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> SoftDeleteAsync(int id)
    {
        var existing = await db.Announcements.FindAsync(id);
        if (existing is null) return false;

        existing.IsDeleted = true;
        await db.SaveChangesAsync();
        return true;
    }
}
