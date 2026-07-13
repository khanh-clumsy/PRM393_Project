using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class TeachingAssignmentRepository(Prm393dbContext db) : ITeachingAssignmentRepository
{
    public async Task<IEnumerable<TeachingAssignment>> GetAllAsync() =>
        await db.TeachingAssignments
            .Include(ta => ta.Class)
            .Include(ta => ta.Subject)
            .ToListAsync();

    public async Task<IEnumerable<TeachingAssignment>> GetByTeacherAsync(int teacherId) =>
        await db.TeachingAssignments
            .Include(ta => ta.Class)
            .Include(ta => ta.Subject)
            .Where(ta => ta.TeacherId == teacherId).ToListAsync();

    public async Task<IEnumerable<TeachingAssignment>> GetByClassAsync(int classId) =>
        await db.TeachingAssignments
            .Include(ta => ta.Class)
            .Include(ta => ta.Subject)
            .Where(ta => ta.ClassId == classId).ToListAsync();

    public async Task<IEnumerable<TeachingAssignment>> GetBySemesterAsync(int semesterId) =>
        await db.TeachingAssignments
            .Include(ta => ta.Class)
            .Include(ta => ta.Subject)
            .Where(ta => ta.SemesterId == semesterId).ToListAsync();

    public async Task<IEnumerable<TeachingAssignment>> GetByDepartmentAsync(int departmentId) =>
        await db.TeachingAssignments
            .Include(ta => ta.Class)
            .Include(ta => ta.Subject)
            .Include(ta => ta.Teacher)
            .Where(ta => ta.Teacher != null && ta.Teacher.DepartmentId == departmentId)
            .ToListAsync();

    public async Task<TeachingAssignment?> GetByIdAsync(int id) =>
        await db.TeachingAssignments
            .Include(ta => ta.Class)
            .Include(ta => ta.Subject)
            .FirstOrDefaultAsync(ta => ta.TeachingAssignmentId == id);

    public async Task<TeachingAssignment> CreateAsync(TeachingAssignment ta)
    {
        db.TeachingAssignments.Add(ta);
        await db.SaveChangesAsync();
        return ta;
    }

    public async Task<TeachingAssignment?> UpdateAsync(TeachingAssignment ta)
    {
        var existing = await db.TeachingAssignments.FindAsync(ta.TeachingAssignmentId);
        if (existing is null) return null;

        existing.TeacherId = ta.TeacherId;
        existing.ClassId = ta.ClassId;
        existing.SubjectId = ta.SubjectId;
        existing.SemesterId = ta.SemesterId;
        await db.SaveChangesAsync();

        return await GetByIdAsync(ta.TeachingAssignmentId);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var ta = await db.TeachingAssignments.FindAsync(id);
        if (ta is null) return false;

        db.TeachingAssignments.Remove(ta);
        await db.SaveChangesAsync();
        return true;
    }
}
