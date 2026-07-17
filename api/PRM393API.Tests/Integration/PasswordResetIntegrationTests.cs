using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Integration;

public class PasswordResetIntegrationTests : IDisposable
{
    private readonly IntegrationServiceProvider _ctx = new();

    [Fact]
    public async Task PasswordResetFlow_ChangesPasswordAndRevokesRefreshTokens()
    {
        var user = _ctx.Db.Users.First(u => u.UserId == IntegrationScenarioSeed.Student01Id);
        user.Email = "student01@fschool.edu.vn";
        var oldRefresh = new RefreshToken
        {
            UserId = user.UserId,
            Token = "old-refresh-token",
            ExpiresAt = DateTime.UtcNow.AddDays(7),
            CreatedAt = DateTime.UtcNow,
            IsRevoked = false,
        };
        _ctx.Db.RefreshTokens.Add(oldRefresh);
        await _ctx.Db.SaveChangesAsync();

        var forgot = await _ctx.Auth.ForgotPasswordAsync(new ForgotPasswordDto(" Student01@FSchool.edu.vn "));

        Assert.Equal(ForgotPasswordResult.Success, forgot);
        Assert.Equal(1, _ctx.Email.SendCount);
        Assert.NotNull(_ctx.Email.LastCode);

        var reset = await _ctx.Auth.ResetPasswordAsync(
            new ResetPasswordDto("student01@fschool.edu.vn", _ctx.Email.LastCode!, "newpassword"));

        Assert.Equal(ResetPasswordResult.Success, reset);
        Assert.Null(user.PasswordResetCode);
        Assert.Null(user.PasswordResetCodeExpiresAt);
        Assert.True(oldRefresh.IsRevoked);

        var oldLogin = await _ctx.Auth.LoginAsync(new LoginRequestDto(user.PhoneNumber!, "12345678"));
        var newLogin = await _ctx.Auth.LoginAsync(new LoginRequestDto(user.PhoneNumber!, "newpassword"));
        var refresh = await _ctx.Auth.RefreshAsync(new RefreshRequestDto("old-refresh-token"));

        Assert.Equal(LoginFailureReason.InvalidCredentials, oldLogin.Failure);
        Assert.Equal(LoginFailureReason.None, newLogin.Failure);
        Assert.Null(refresh);
    }

    public void Dispose() => _ctx.Dispose();
}
