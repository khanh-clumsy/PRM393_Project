using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class ParentStudentRepository(Prm393dbContext db) : IParentStudentRepository
{
    public async Task<IEnumerable<ParentStudent>> GetByParentAsync(int parentId) =>
        await db.ParentStudents.Include(ps => ps.Student).Include(ps => ps.Parent).Where(ps => ps.ParentId == parentId).ToListAsync();

    public async Task<IEnumerable<ParentStudent>> GetByStudentAsync(int studentId) =>
        await db.ParentStudents.Include(ps => ps.Parent).Include(ps => ps.Student).Where(ps => ps.StudentId == studentId).ToListAsync();

    public async Task<ParentStudent?> GetByIdAsync(int id) =>
        await db.ParentStudents.Include(ps => ps.Student).Include(ps => ps.Parent).FirstOrDefaultAsync(ps => ps.ParentStudentId == id);

    public async Task<ParentStudent> CreateAsync(ParentStudent ps)
    {
        db.ParentStudents.Add(ps);
        await db.SaveChangesAsync();
        return ps;
    }

    public async Task<ParentStudent?> UpdateAsync(int id, ParentStudent updated)
    {
        var ps = await db.ParentStudents.FindAsync(id);
        if (ps is null) return null;

        ps.Relationship = updated.Relationship;
        await db.SaveChangesAsync();
        return ps;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var ps = await db.ParentStudents.FindAsync(id);
        if (ps is null) return false;

        db.ParentStudents.Remove(ps);
        await db.SaveChangesAsync();
        return true;
    }
}
