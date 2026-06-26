using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class AuthRepository(Prm393dbContext db) : IAuthRepository
{
    public async Task<User?> GetByPhoneAsync(string phoneNumber) =>
        await db.Users.Include(u => u.Role).FirstOrDefaultAsync(u => u.PhoneNumber == phoneNumber);

    public async Task<User?> GetUserByIdAsync(int id) =>
        await db.Users.Include(u => u.Role).FirstOrDefaultAsync(u => u.UserId == id);

    public async Task<RefreshToken?> GetRefreshTokenAsync(string token) =>
        await db.RefreshTokens.FirstOrDefaultAsync(t => t.Token == token);

    public async Task<RefreshToken> CreateRefreshTokenAsync(RefreshToken token)
    {
        db.RefreshTokens.Add(token);
        await db.SaveChangesAsync();
        return token;
    }

    public async Task RevokeRefreshTokenAsync(RefreshToken token)
    {
        token.IsRevoked = true;
        await db.SaveChangesAsync();
    }
}
