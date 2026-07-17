using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class StudentRequestRepository(Prm393dbContext db) : IStudentRequestRepository
{
    public async Task<StudentRequest?> GetByIdAsync(int id) =>
        await db.StudentRequests
            .Include(r => r.Student)
            .Include(r => r.RequestedByNavigation)
            .FirstOrDefaultAsync(r => r.StudentRequestId == id);

    public async Task<IEnumerable<StudentRequest>> GetByStudentAsync(int studentId) =>
        await db.StudentRequests
            .Include(r => r.Student)
            .Include(r => r.RequestedByNavigation)
            .Where(r => r.StudentId == studentId)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

    public async Task<IEnumerable<StudentRequest>> GetPendingAsync() =>
        await db.StudentRequests
            .Include(r => r.Student)
            .Include(r => r.RequestedByNavigation)
            .Where(r => r.Status == "Pending")
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

    public async Task<IEnumerable<StudentRequest>> GetPendingByClassIdsAsync(IEnumerable<int> classIds)
    {
        var ids = classIds.Distinct().ToList();
        return await db.StudentRequests
            .Include(r => r.Student)
            .Include(r => r.RequestedByNavigation)
            .Where(r => r.Status == "Pending" &&
                        db.StudentClasses.Any(sc => sc.StudentId == r.StudentId && ids.Contains(sc.ClassId)))
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();
    }

    public async Task<bool> StudentHasClassAsync(int studentId, IEnumerable<int> classIds)
    {
        var ids = classIds.Distinct().ToList();
        return await db.StudentClasses.AnyAsync(sc => sc.StudentId == studentId && ids.Contains(sc.ClassId));
    }

    public async Task<StudentRequest> CreateAsync(StudentRequest request)
    {
        db.StudentRequests.Add(request);
        await db.SaveChangesAsync();
        return request;
    }

    public async Task<StudentRequest?> ReviewAsync(int id, StudentRequest updated)
    {
        var existing = await db.StudentRequests.FindAsync(id);
        if (existing is null) return null;

        existing.Status = updated.Status;
        existing.ReviewedBy = updated.ReviewedBy;
        existing.ReviewNote = updated.ReviewNote;
        existing.ReviewedAt = updated.ReviewedAt;
        await db.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var existing = await db.StudentRequests.FindAsync(id);
        if (existing is null) return false;

        db.StudentRequests.Remove(existing);
        await db.SaveChangesAsync();
        return true;
    }
}
