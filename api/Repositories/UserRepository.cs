using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class UserRepository(Prm393dbContext db) : IUserRepository
{
    public async Task<IEnumerable<User>> GetAllAsync() =>
        await db.Users.ToListAsync();

    public async Task<User?> GetByIdAsync(int id) =>
        await db.Users.Include(u => u.Role).FirstOrDefaultAsync(u => u.UserId == id);

    public async Task<User?> GetByEmailAsync(string email) =>
        await db.Users.FirstOrDefaultAsync(u => u.Email == email);

    public async Task<User?> GetByUsernameAsync(string username) =>
        await db.Users.FirstOrDefaultAsync(u => u.Username == username);

    public async Task<IEnumerable<User>> GetByRoleAsync(int roleId) =>
        await db.Users.Where(u => u.RoleId == roleId).ToListAsync();

    public async Task<IEnumerable<User>> GetByDepartmentAsync(int departmentId) =>
        await db.Users.Where(u => u.DepartmentId == departmentId).ToListAsync();

    public async Task<User> CreateAsync(User user)
    {
        db.Users.Add(user);
        await db.SaveChangesAsync();
        return user;
    }

    public async Task<User?> UpdateAsync(int id, User updated)
    {
        var user = await db.Users.FindAsync(id);
        if (user is null) return null;

        user.FullName = updated.FullName;
        user.Email = updated.Email;
        user.PhoneNumber = updated.PhoneNumber;
        user.Address = updated.Address;
        user.Gender = updated.Gender;
        user.AvatarUrl = updated.AvatarUrl;
        user.IsActive = updated.IsActive;
        user.UpdatedAt = updated.UpdatedAt;
        await db.SaveChangesAsync();
        return user;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var user = await db.Users.FindAsync(id);
        if (user is null) return false;

        db.Users.Remove(user);
        await db.SaveChangesAsync();
        return true;
    }
}
