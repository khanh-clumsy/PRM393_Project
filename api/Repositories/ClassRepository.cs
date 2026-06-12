using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class ClassRepository(Prm393dbContext db) : IClassRepository
{
    public async Task<IEnumerable<Class>> GetAllAsync() =>
        await db.Classes.ToListAsync();

    public async Task<IEnumerable<Class>> GetByAcademicYearAsync(int academicYearId) =>
        await db.Classes.Where(c => c.AcademicYearId == academicYearId).ToListAsync();

    public async Task<Class?> GetByIdAsync(int id) =>
        await db.Classes.FindAsync(id);

    public async Task<Class> CreateAsync(Class cls)
    {
        db.Classes.Add(cls);
        await db.SaveChangesAsync();
        return cls;
    }

    public async Task<Class?> UpdateAsync(int id, Class updated)
    {
        var cls = await db.Classes.FindAsync(id);
        if (cls is null) return null;

        cls.ClassName = updated.ClassName;
        cls.HomeroomTeacherId = updated.HomeroomTeacherId;
        await db.SaveChangesAsync();
        return cls;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var cls = await db.Classes.FindAsync(id);
        if (cls is null) return false;

        db.Classes.Remove(cls);
        await db.SaveChangesAsync();
        return true;
    }
}
