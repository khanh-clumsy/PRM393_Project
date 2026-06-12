using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class AssessmentTypeRepository(Prm393dbContext db) : IAssessmentTypeRepository
{
    public async Task<IEnumerable<AssessmentType>> GetAllAsync() =>
        await db.AssessmentTypes.ToListAsync();

    public async Task<AssessmentType?> GetByIdAsync(int id) =>
        await db.AssessmentTypes.FindAsync(id);

    public async Task<AssessmentType> CreateAsync(AssessmentType type)
    {
        db.AssessmentTypes.Add(type);
        await db.SaveChangesAsync();
        return type;
    }

    public async Task<AssessmentType?> UpdateAsync(int id, AssessmentType updated)
    {
        var existing = await db.AssessmentTypes.FindAsync(id);
        if (existing is null) return null;

        existing.TypeName = updated.TypeName;
        existing.Weight = updated.Weight;
        await db.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var existing = await db.AssessmentTypes.FindAsync(id);
        if (existing is null) return false;

        db.AssessmentTypes.Remove(existing);
        await db.SaveChangesAsync();
        return true;
    }
}
