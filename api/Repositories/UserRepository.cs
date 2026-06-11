using Microsoft.EntityFrameworkCore;
using PRM393API.Common;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class UserRepository(AppDbContext db) : IUserRepository
{
    public async Task<IEnumerable<User>> GetAllAsync() =>
        await db.Users.ToListAsync();

    public async Task<User?> GetByIdAsync(int id) =>
        await db.Users.FindAsync(id);

    public async Task<User?> GetByEmailAsync(string email) =>
        await db.Users.FirstOrDefaultAsync(u => u.Email == email);

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

        user.Username = updated.Username;
        user.Email = updated.Email;
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
