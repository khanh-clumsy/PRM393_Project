using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class SemesterRepository(Prm393dbContext db) : ISemesterRepository
{
    public async Task<IEnumerable<Semester>> GetAllAsync() =>
        await db.Semesters.ToListAsync();

    public async Task<IEnumerable<Semester>> GetByAcademicYearAsync(int academicYearId) =>
        await db.Semesters
            .Where(s => s.AcademicYearId == academicYearId)
            .OrderBy(s => s.StartDate)
            .ToListAsync();

    public async Task<Semester?> GetByIdAsync(int id) =>
        await db.Semesters.FindAsync(id);

    public async Task<Semester> CreateAsync(Semester semester)
    {
        db.Semesters.Add(semester);
        await db.SaveChangesAsync();
        return semester;
    }

    public async Task<Semester?> UpdateAsync(int id, Semester updated)
    {
        var semester = await db.Semesters.FindAsync(id);
        if (semester is null) return null;

        semester.SemesterName = updated.SemesterName;
        semester.StartDate = updated.StartDate;
        semester.EndDate = updated.EndDate;
        await db.SaveChangesAsync();
        return semester;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var semester = await db.Semesters.FindAsync(id);
        if (semester is null) return false;

        db.Semesters.Remove(semester);
        await db.SaveChangesAsync();
        return true;
    }
}
