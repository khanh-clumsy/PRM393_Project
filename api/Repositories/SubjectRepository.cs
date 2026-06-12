using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class SubjectRepository(Prm393dbContext db) : ISubjectRepository
{
    public async Task<IEnumerable<Subject>> GetAllAsync() =>
        await db.Subjects.ToListAsync();

    public async Task<Subject?> GetByIdAsync(int id) =>
        await db.Subjects.FindAsync(id);

    public async Task<Subject> CreateAsync(Subject subject)
    {
        db.Subjects.Add(subject);
        await db.SaveChangesAsync();
        return subject;
    }

    public async Task<Subject?> UpdateAsync(int id, Subject updated)
    {
        var subject = await db.Subjects.FindAsync(id);
        if (subject is null) return null;

        subject.SubjectCode = updated.SubjectCode;
        subject.SubjectName = updated.SubjectName;
        subject.IsActive = updated.IsActive;
        await db.SaveChangesAsync();
        return subject;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var subject = await db.Subjects.FindAsync(id);
        if (subject is null) return false;

        db.Subjects.Remove(subject);
        await db.SaveChangesAsync();
        return true;
    }
}
