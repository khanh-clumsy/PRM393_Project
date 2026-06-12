using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class AssignmentRepository(Prm393dbContext db) : IAssignmentRepository
{
    public async Task<IEnumerable<Assignment>> GetAllAsync() =>
        await db.Assignments.Where(a => !a.IsDeleted).ToListAsync();

    public async Task<Assignment?> GetByIdAsync(int id) =>
        await db.Assignments.FirstOrDefaultAsync(a => a.AssignmentId == id && !a.IsDeleted);

    public async Task<IEnumerable<Assignment>> GetByTeachingAssignmentAsync(int teachingAssignmentId) =>
        await db.Assignments.Where(a => a.TeachingAssignmentId == teachingAssignmentId && !a.IsDeleted).ToListAsync();

    public async Task<Assignment> CreateAsync(Assignment assignment)
    {
        db.Assignments.Add(assignment);
        await db.SaveChangesAsync();
        return assignment;
    }

    public async Task<Assignment?> UpdateAsync(int id, Assignment updated)
    {
        var existing = await db.Assignments.FirstOrDefaultAsync(a => a.AssignmentId == id && !a.IsDeleted);
        if (existing is null) return null;

        existing.Title = updated.Title;
        existing.Description = updated.Description;
        existing.AttachmentUrl = updated.AttachmentUrl;
        existing.DueDate = updated.DueDate;
        existing.UpdatedAt = updated.UpdatedAt;
        await db.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> SoftDeleteAsync(int id)
    {
        var existing = await db.Assignments.FindAsync(id);
        if (existing is null) return false;

        existing.IsDeleted = true;
        await db.SaveChangesAsync();
        return true;
    }
}
