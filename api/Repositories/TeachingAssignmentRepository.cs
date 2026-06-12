using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class TeachingAssignmentRepository(Prm393dbContext db) : ITeachingAssignmentRepository
{
    public async Task<IEnumerable<TeachingAssignment>> GetAllAsync() =>
        await db.TeachingAssignments.ToListAsync();

    public async Task<IEnumerable<TeachingAssignment>> GetByTeacherAsync(int teacherId) =>
        await db.TeachingAssignments.Where(ta => ta.TeacherId == teacherId).ToListAsync();

    public async Task<IEnumerable<TeachingAssignment>> GetByClassAsync(int classId) =>
        await db.TeachingAssignments.Where(ta => ta.ClassId == classId).ToListAsync();

    public async Task<IEnumerable<TeachingAssignment>> GetBySemesterAsync(int semesterId) =>
        await db.TeachingAssignments.Where(ta => ta.SemesterId == semesterId).ToListAsync();

    public async Task<TeachingAssignment?> GetByIdAsync(int id) =>
        await db.TeachingAssignments.FindAsync(id);

    public async Task<TeachingAssignment> CreateAsync(TeachingAssignment ta)
    {
        db.TeachingAssignments.Add(ta);
        await db.SaveChangesAsync();
        return ta;
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
