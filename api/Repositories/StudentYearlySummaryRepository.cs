using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class StudentYearlySummaryRepository(Prm393dbContext db) : IStudentYearlySummaryRepository
{
    public async Task<StudentYearlySummary?> GetByIdAsync(int id) =>
        await db.StudentYearlySummaries.FindAsync(id);

    public async Task<IEnumerable<StudentYearlySummary>> GetByStudentAsync(int studentId) =>
        await db.StudentYearlySummaries.Where(s => s.StudentId == studentId).ToListAsync();

    public async Task<IEnumerable<StudentYearlySummary>> GetByYearAsync(int academicYearId) =>
        await db.StudentYearlySummaries.Where(s => s.AcademicYearId == academicYearId).ToListAsync();

    public async Task<StudentYearlySummary> CreateAsync(StudentYearlySummary summary)
    {
        db.StudentYearlySummaries.Add(summary);
        await db.SaveChangesAsync();
        return summary;
    }

    public async Task<StudentYearlySummary?> UpdateAsync(int id, StudentYearlySummary updated)
    {
        var existing = await db.StudentYearlySummaries.FindAsync(id);
        if (existing is null) return null;

        existing.YearlyGpa = updated.YearlyGpa;
        existing.YearlyConduct = updated.YearlyConduct;
        existing.RankId = updated.RankId;
        await db.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var existing = await db.StudentYearlySummaries.FindAsync(id);
        if (existing is null) return false;

        db.StudentYearlySummaries.Remove(existing);
        await db.SaveChangesAsync();
        return true;
    }
}
