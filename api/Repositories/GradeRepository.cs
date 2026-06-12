using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class GradeRepository(Prm393dbContext db) : IGradeRepository
{
    public async Task<Grade?> GetByIdAsync(int id) =>
        await db.Grades.FindAsync(id);

    public async Task<IEnumerable<Grade>> GetByAssessmentAsync(int assessmentId) =>
        await db.Grades.Where(g => g.AssessmentId == assessmentId).ToListAsync();

    public async Task<IEnumerable<Grade>> GetByStudentAsync(int studentId) =>
        await db.Grades.Where(g => g.StudentId == studentId).ToListAsync();

    public async Task<Grade> CreateAsync(Grade grade)
    {
        db.Grades.Add(grade);
        await db.SaveChangesAsync();
        return grade;
    }

    public async Task<Grade?> UpdateAsync(int id, Grade updated)
    {
        var existing = await db.Grades.FindAsync(id);
        if (existing is null) return null;

        existing.Score = updated.Score;
        existing.Comment = updated.Comment;
        await db.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var existing = await db.Grades.FindAsync(id);
        if (existing is null) return false;

        db.Grades.Remove(existing);
        await db.SaveChangesAsync();
        return true;
    }
}
