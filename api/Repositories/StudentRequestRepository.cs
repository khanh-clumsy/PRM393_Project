using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class StudentRequestRepository(Prm393dbContext db) : IStudentRequestRepository
{
    public async Task<StudentRequest?> GetByIdAsync(int id) =>
        await db.StudentRequests.FindAsync(id);

    public async Task<IEnumerable<StudentRequest>> GetByStudentAsync(int studentId) =>
        await db.StudentRequests.Where(r => r.StudentId == studentId).ToListAsync();

    public async Task<IEnumerable<StudentRequest>> GetPendingAsync() =>
        await db.StudentRequests.Where(r => r.Status == "Pending").ToListAsync();

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
