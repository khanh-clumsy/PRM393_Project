using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class AcademicYearRepository(Prm393dbContext db) : IAcademicYearRepository
{
    public async Task<IEnumerable<AcademicYear>> GetAllAsync() =>
        await db.AcademicYears.OrderBy(y => y.StartDate).ToListAsync();

    public async Task<AcademicYear?> GetByIdAsync(int id) =>
        await db.AcademicYears.FindAsync(id);

    public async Task<AcademicYear> CreateAsync(AcademicYear year)
    {
        db.AcademicYears.Add(year);
        await db.SaveChangesAsync();
        return year;
    }

    public async Task<AcademicYear?> UpdateAsync(int id, AcademicYear updated)
    {
        var year = await db.AcademicYears.FindAsync(id);
        if (year is null) return null;

        year.YearName = updated.YearName;
        year.StartDate = updated.StartDate;
        year.EndDate = updated.EndDate;
        year.IsActive = updated.IsActive;
        await db.SaveChangesAsync();
        return year;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var year = await db.AcademicYears.FindAsync(id);
        if (year is null) return false;

        db.AcademicYears.Remove(year);
        await db.SaveChangesAsync();
        return true;
    }
}
