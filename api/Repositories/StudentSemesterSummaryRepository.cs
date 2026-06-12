using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class StudentSemesterSummaryRepository(Prm393dbContext db) : IStudentSemesterSummaryRepository
{
    public async Task<StudentSemesterSummary?> GetByIdAsync(int id) =>
        await db.StudentSemesterSummaries.FindAsync(id);

    public async Task<IEnumerable<StudentSemesterSummary>> GetByStudentAsync(int studentId) =>
        await db.StudentSemesterSummaries.Where(s => s.StudentId == studentId).ToListAsync();

    public async Task<IEnumerable<StudentSemesterSummary>> GetBySemesterAsync(int semesterId) =>
        await db.StudentSemesterSummaries.Where(s => s.SemesterId == semesterId).ToListAsync();

    public async Task<StudentSemesterSummary> CreateAsync(StudentSemesterSummary summary)
    {
        db.StudentSemesterSummaries.Add(summary);
        await db.SaveChangesAsync();
        return summary;
    }

    public async Task<StudentSemesterSummary?> UpdateAsync(int id, StudentSemesterSummary updated)
    {
        var existing = await db.StudentSemesterSummaries.FindAsync(id);
        if (existing is null) return null;

        existing.Gpa = updated.Gpa;
        existing.Conduct = updated.Conduct;
        existing.RankId = updated.RankId;
        await db.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var existing = await db.StudentSemesterSummaries.FindAsync(id);
        if (existing is null) return false;

        db.StudentSemesterSummaries.Remove(existing);
        await db.SaveChangesAsync();
        return true;
    }
}
