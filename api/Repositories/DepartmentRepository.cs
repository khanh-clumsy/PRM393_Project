using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class DepartmentRepository(Prm393dbContext db) : IDepartmentRepository
{
    public async Task<IEnumerable<Department>> GetAllAsync() =>
        await db.Departments.ToListAsync();

    public async Task<Department?> GetByIdAsync(int id) =>
        await db.Departments.FindAsync(id);

    public async Task<Department> CreateAsync(Department dept)
    {
        db.Departments.Add(dept);
        await db.SaveChangesAsync();
        return dept;
    }

    public async Task<Department?> UpdateAsync(int id, Department updated)
    {
        var dept = await db.Departments.FindAsync(id);
        if (dept is null) return null;

        dept.DepartmentName = updated.DepartmentName;
        dept.Description = updated.Description;
        await db.SaveChangesAsync();
        return dept;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var dept = await db.Departments.FindAsync(id);
        if (dept is null) return false;

        db.Departments.Remove(dept);
        await db.SaveChangesAsync();
        return true;
    }
}
