using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class AssessmentRepository(Prm393dbContext db) : IAssessmentRepository
{
    public async Task<IEnumerable<Assessment>> GetAllAsync() =>
        await db.Assessments.ToListAsync();

    public async Task<Assessment?> GetByIdAsync(int id) =>
        await db.Assessments.FindAsync(id);

    public async Task<IEnumerable<Assessment>> GetByTeachingAssignmentAsync(int teachingAssignmentId) =>
        await db.Assessments.Where(a => a.TeachingAssignmentId == teachingAssignmentId).ToListAsync();

    public async Task<Assessment> CreateAsync(Assessment assessment)
    {
        db.Assessments.Add(assessment);
        await db.SaveChangesAsync();
        return assessment;
    }

    public async Task<Assessment?> UpdateAsync(int id, Assessment updated)
    {
        var existing = await db.Assessments.FindAsync(id);
        if (existing is null) return null;

        existing.AssessmentName = updated.AssessmentName;
        existing.AssessmentDate = updated.AssessmentDate;
        existing.MaxScore = updated.MaxScore;
        await db.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var existing = await db.Assessments.FindAsync(id);
        if (existing is null) return false;

        db.Assessments.Remove(existing);
        await db.SaveChangesAsync();
        return true;
    }
}
