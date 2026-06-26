using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IAuthRepository
{
    Task<User?> GetByPhoneAsync(string phoneNumber);
    Task<User?> GetUserByIdAsync(int id);
    Task<RefreshToken?> GetRefreshTokenAsync(string token);
    Task<RefreshToken> CreateRefreshTokenAsync(RefreshToken token);
    Task RevokeRefreshTokenAsync(RefreshToken token);
}
