using PRM393API.Common;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class AuthService(IAuthRepository repo, IUserRepository userRepo, JwtHelper jwt) : IAuthService
{
    public async Task<AuthTokenDto?> LoginAsync(LoginRequestDto dto)
    {
        var user = await repo.GetByPhoneAsync(dto.PhoneNumber);
        if (user is null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
            return null;

        var accessToken = jwt.GenerateToken(user);
        var refreshToken = await CreateRefreshToken(user.UserId);
        return new AuthTokenDto(accessToken, refreshToken.Token, ToDto(user));
    }

    public async Task<AuthTokenDto?> RefreshAsync(RefreshRequestDto dto)
    {
        var existing = await repo.GetRefreshTokenAsync(dto.RefreshToken);
        if (existing is null || existing.IsRevoked || existing.ExpiresAt <= DateTime.UtcNow)
            return null;

        await repo.RevokeRefreshTokenAsync(existing);

        var user = await userRepo.GetByIdAsync(existing.UserId);
        if (user is null) return null;

        var accessToken = jwt.GenerateToken(user);
        var newRefresh = await CreateRefreshToken(user.UserId);
        return new AuthTokenDto(accessToken, newRefresh.Token, ToDto(user));
    }

    private async Task<RefreshToken> CreateRefreshToken(int userId)
    {
        var tokenBytes = Guid.NewGuid().ToByteArray().Concat(Guid.NewGuid().ToByteArray()).ToArray();
        var token = new RefreshToken
        {
            UserId = userId,
            Token = Convert.ToBase64String(tokenBytes),
            ExpiresAt = DateTime.UtcNow.AddDays(30),
            IsRevoked = false,
            CreatedAt = DateTime.UtcNow,
        };
        return await repo.CreateRefreshTokenAsync(token);
    }

    private static UserDto ToDto(User u) => new(
        u.UserId, u.Username, u.FullName, u.Email, u.PhoneNumber,
        u.RoleId, u.DepartmentId, u.IsActive, u.CreatedAt);
}
