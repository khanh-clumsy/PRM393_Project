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
            .ToListAsync();

    public async Task<Announcement> CreateAsync(Announcement announcement, List<int?> targetClassIds)
    {
        db.Announcements.Add(announcement);
        await db.SaveChangesAsync();

        var targets = targetClassIds.Select(classId => new AnnouncementTarget
        {
            AnnouncementId = announcement.AnnouncementId,
            ClassId = classId,
        });
        db.AnnouncementTargets.AddRange(targets);
        await db.SaveChangesAsync();

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
