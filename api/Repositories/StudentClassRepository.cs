using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class StudentClassRepository(Prm393dbContext db) : IStudentClassRepository
{
    public async Task<IEnumerable<StudentClass>> GetByClassAsync(int classId) =>
        await db.StudentClasses.Where(sc => sc.ClassId == classId).ToListAsync();

    public async Task<IEnumerable<StudentClass>> GetByStudentAsync(int studentId) =>
        await db.StudentClasses.Where(sc => sc.StudentId == studentId).ToListAsync();

    public async Task<StudentClass?> GetByIdAsync(int id) =>
        await db.StudentClasses.FindAsync(id);

    public async Task<StudentClass> CreateAsync(StudentClass sc)
    {
        db.StudentClasses.Add(sc);
        await db.SaveChangesAsync();
        return sc;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var sc = await db.StudentClasses.FindAsync(id);
        if (sc is null) return false;

        db.StudentClasses.Remove(sc);
        await db.SaveChangesAsync();
        return true;
    }
}
