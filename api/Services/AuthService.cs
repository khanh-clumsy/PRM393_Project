using System.Security.Cryptography;
using PRM393API.Common;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class AuthService(
    IAuthRepository repo,
    JwtHelper jwt,
    IEmailService emailService) : IAuthService
{
    private const int ResetCodeMinutes = 10;

    public async Task<LoginResultDto> LoginAsync(LoginRequestDto dto)
    {
        var user = await repo.GetByPhoneAsync(dto.PhoneNumber);
        if (user is null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
            return new LoginResultDto(null, LoginFailureReason.InvalidCredentials);

        if (!user.IsActive)
            return new LoginResultDto(null, LoginFailureReason.AccountLocked);

        var accessToken = jwt.GenerateToken(user);
        var refreshToken = await CreateRefreshToken(user.UserId);
        return new LoginResultDto(new AuthTokenDto(accessToken, refreshToken.Token, ToDto(user)));
    }

    public async Task<AuthTokenDto?> RefreshAsync(RefreshRequestDto dto)
    {
        var existing = await repo.GetRefreshTokenAsync(dto.RefreshToken);
        if (existing is null || existing.IsRevoked || existing.ExpiresAt <= DateTime.UtcNow)
            return null;

        await repo.RevokeRefreshTokenAsync(existing);

        var user = await repo.GetUserByIdAsync(existing.UserId);
        if (user is null || !user.IsActive) return null;

        var accessToken = jwt.GenerateToken(user);
        var newRefresh = await CreateRefreshToken(user.UserId);
        return new AuthTokenDto(accessToken, newRefresh.Token, ToDto(user));
    }

    public async Task<ForgotPasswordResult> ForgotPasswordAsync(ForgotPasswordDto dto)
    {
        var email = NormalizeEmail(dto.Email);
        if (string.IsNullOrWhiteSpace(email))
            return ForgotPasswordResult.Success;

        var user = await repo.GetByEmailAsync(email);
        if (user is null || !user.IsActive || IsPlaceholderEmail(user.Email))
            return ForgotPasswordResult.Success;

        var code = GenerateResetCode();
        user.PasswordResetCode = code;
        user.PasswordResetCodeExpiresAt = DateTime.UtcNow.AddMinutes(ResetCodeMinutes);
        await repo.SaveChangesAsync();

        try
        {
            await emailService.SendPasswordResetCodeAsync(user.Email, code);
            return ForgotPasswordResult.Success;
        }
        catch
        {
            user.PasswordResetCode = null;
            user.PasswordResetCodeExpiresAt = null;
            await repo.SaveChangesAsync();
            return ForgotPasswordResult.EmailFailed;
        }
    }

    public async Task<ResetPasswordResult> ResetPasswordAsync(ResetPasswordDto dto)
    {
        var email = NormalizeEmail(dto.Email);
        var code = dto.Code?.Trim() ?? "";
        if (string.IsNullOrWhiteSpace(email) || code.Length != 6 || (dto.NewPassword?.Length ?? 0) < 8)
            return ResetPasswordResult.InvalidOrExpired;

        var user = await repo.GetByEmailAsync(email);
        if (user is null ||
            !user.IsActive ||
            IsPlaceholderEmail(user.Email) ||
            user.PasswordResetCode != code ||
            user.PasswordResetCodeExpiresAt is null ||
            user.PasswordResetCodeExpiresAt <= DateTime.UtcNow)
        {
            return ResetPasswordResult.InvalidOrExpired;
        }

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);
        user.PasswordResetCode = null;
        user.PasswordResetCodeExpiresAt = null;
        user.UpdatedAt = DateTime.UtcNow;
        await repo.RevokeAllRefreshTokensAsync(user.UserId);
        await repo.SaveChangesAsync();

        return ResetPasswordResult.Success;
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

    private static string NormalizeEmail(string? email) =>
        (email ?? string.Empty).Trim().ToLowerInvariant();

    private static bool IsPlaceholderEmail(string email) =>
        email.EndsWith("@invalid.local", StringComparison.OrdinalIgnoreCase);

    private static string GenerateResetCode() =>
        RandomNumberGenerator.GetInt32(0, 1_000_000).ToString("D6");

    private static UserDto ToDto(User u) => new(
        u.UserId, u.Username, u.FullName, u.Email, u.PhoneNumber,
        u.RoleId, u.Role?.RoleName ?? "", u.DepartmentId,
        u.DateOfBirth, u.Gender, u.Address, u.AvatarUrl,
        u.IsActive, u.CreatedAt);
}
