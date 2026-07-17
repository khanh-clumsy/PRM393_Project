using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class AuthServiceTests
{
    private readonly Mock<IAuthRepository> _authRepo = new();
    private readonly FakeEmailService _email = new();
    private readonly AuthService _sut;

    public AuthServiceTests()
    {
        _sut = new AuthService(_authRepo.Object, TestDataFactory.CreateJwtHelper(), _email);
    }

    [Fact]
    public async Task LoginAsync_ValidActiveUser_ReturnsToken()
    {
        var user = TestDataFactory.CreateUser(isActive: true);
        _authRepo.Setup(r => r.GetByPhoneAsync(TestDataFactory.DefaultPhone)).ReturnsAsync(user);
        _authRepo.Setup(r => r.CreateRefreshTokenAsync(It.IsAny<RefreshToken>()))
            .ReturnsAsync((RefreshToken t) => t);

        var result = await _sut.LoginAsync(new LoginRequestDto(TestDataFactory.DefaultPhone, TestDataFactory.DefaultPassword));

        Assert.Equal(LoginFailureReason.None, result.Failure);
        Assert.NotNull(result.Token);
        Assert.False(string.IsNullOrWhiteSpace(result.Token!.AccessToken));
        Assert.False(string.IsNullOrWhiteSpace(result.Token.RefreshToken));
        Assert.True(result.Token.User.IsActive);
    }

    [Fact]
    public async Task LoginAsync_WrongPassword_ReturnsInvalidCredentials()
    {
        var user = TestDataFactory.CreateUser(isActive: true);
        _authRepo.Setup(r => r.GetByPhoneAsync(TestDataFactory.DefaultPhone)).ReturnsAsync(user);

        var result = await _sut.LoginAsync(new LoginRequestDto(TestDataFactory.DefaultPhone, "wrong-password"));

        Assert.Equal(LoginFailureReason.InvalidCredentials, result.Failure);
        Assert.Null(result.Token);
    }

    [Fact]
    public async Task LoginAsync_UnknownPhone_ReturnsInvalidCredentials()
    {
        _authRepo.Setup(r => r.GetByPhoneAsync("0999999999")).ReturnsAsync((User?)null);

        var result = await _sut.LoginAsync(new LoginRequestDto("0999999999", TestDataFactory.DefaultPassword));

        Assert.Equal(LoginFailureReason.InvalidCredentials, result.Failure);
        Assert.Null(result.Token);
    }

    [Fact]
    public async Task LoginAsync_InactiveUser_ReturnsAccountLocked()
    {
        var user = TestDataFactory.CreateUser(isActive: false);
        _authRepo.Setup(r => r.GetByPhoneAsync(TestDataFactory.DefaultPhone)).ReturnsAsync(user);

        var result = await _sut.LoginAsync(new LoginRequestDto(TestDataFactory.DefaultPhone, TestDataFactory.DefaultPassword));

        Assert.Equal(LoginFailureReason.AccountLocked, result.Failure);
        Assert.Null(result.Token);
        _authRepo.Verify(r => r.CreateRefreshTokenAsync(It.IsAny<RefreshToken>()), Times.Never);
    }

    [Fact]
    public async Task RefreshAsync_ValidToken_ActiveUser_ReturnsNewTokens()
    {
        var user = TestDataFactory.CreateUser(isActive: true);
        var refresh = TestDataFactory.CreateRefreshToken(user.UserId);
        _authRepo.Setup(r => r.GetRefreshTokenAsync(refresh.Token)).ReturnsAsync(refresh);
        _authRepo.Setup(r => r.GetUserByIdAsync(user.UserId)).ReturnsAsync(user);
        _authRepo.Setup(r => r.RevokeRefreshTokenAsync(refresh)).Returns(Task.CompletedTask);
        _authRepo.Setup(r => r.CreateRefreshTokenAsync(It.IsAny<RefreshToken>()))
            .ReturnsAsync((RefreshToken t) => t);

        var result = await _sut.RefreshAsync(new RefreshRequestDto(refresh.Token));

        Assert.NotNull(result);
        Assert.False(string.IsNullOrWhiteSpace(result!.AccessToken));
        _authRepo.Verify(r => r.RevokeRefreshTokenAsync(refresh), Times.Once);
    }

    [Fact]
    public async Task RefreshAsync_InactiveUser_ReturnsNull()
    {
        var user = TestDataFactory.CreateUser(isActive: false);
        var refresh = TestDataFactory.CreateRefreshToken(user.UserId);
        _authRepo.Setup(r => r.GetRefreshTokenAsync(refresh.Token)).ReturnsAsync(refresh);
        _authRepo.Setup(r => r.GetUserByIdAsync(user.UserId)).ReturnsAsync(user);
        _authRepo.Setup(r => r.RevokeRefreshTokenAsync(refresh)).Returns(Task.CompletedTask);

        var result = await _sut.RefreshAsync(new RefreshRequestDto(refresh.Token));

        Assert.Null(result);
    }

    [Fact]
    public async Task RefreshAsync_ExpiredToken_ReturnsNull()
    {
        var refresh = TestDataFactory.CreateRefreshToken(1, expiresAt: DateTime.UtcNow.AddMinutes(-5));
        _authRepo.Setup(r => r.GetRefreshTokenAsync(refresh.Token)).ReturnsAsync(refresh);

        var result = await _sut.RefreshAsync(new RefreshRequestDto(refresh.Token));

        Assert.Null(result);
        _authRepo.Verify(r => r.RevokeRefreshTokenAsync(It.IsAny<RefreshToken>()), Times.Never);
    }

    [Fact]
    public async Task ForgotPassword_ValidActiveUser_SetsOtpAndSendsEmail()
    {
        var user = TestDataFactory.CreateUser(isActive: true);
        user.Email = "student@fschool.edu.vn";
        _authRepo.Setup(r => r.GetByEmailAsync("student@fschool.edu.vn")).ReturnsAsync(user);

        var result = await _sut.ForgotPasswordAsync(new ForgotPasswordDto(" Student@FSchool.edu.vn "));

        Assert.Equal(ForgotPasswordResult.Success, result);
        Assert.NotNull(user.PasswordResetCode);
        Assert.Equal(6, user.PasswordResetCode!.Length);
        Assert.True(user.PasswordResetCode.All(char.IsDigit));
        Assert.True(user.PasswordResetCodeExpiresAt > DateTime.UtcNow);
        Assert.Equal(1, _email.SendCount);
        Assert.Equal("student@fschool.edu.vn", _email.LastToEmail);
        Assert.Equal(user.PasswordResetCode, _email.LastCode);
        _authRepo.Verify(r => r.SaveChangesAsync(), Times.Once);
    }

    [Fact]
    public async Task ForgotPassword_UnknownOrPlaceholderEmail_ReturnsSuccessWithoutSending()
    {
        _authRepo.Setup(r => r.GetByEmailAsync("missing+1@invalid.local"))
            .ReturnsAsync(new User { Email = "missing+1@invalid.local", IsActive = true });

        var unknown = await _sut.ForgotPasswordAsync(new ForgotPasswordDto("nobody@fschool.edu.vn"));
        var placeholder = await _sut.ForgotPasswordAsync(new ForgotPasswordDto("missing+1@invalid.local"));

        Assert.Equal(ForgotPasswordResult.Success, unknown);
        Assert.Equal(ForgotPasswordResult.Success, placeholder);
        Assert.Equal(0, _email.SendCount);
    }

    [Fact]
    public async Task ForgotPassword_SmtpFails_ClearsOtpAndReturnsEmailFailed()
    {
        var user = TestDataFactory.CreateUser(isActive: true);
        user.Email = "student@fschool.edu.vn";
        _email.ShouldThrow = true;
        _authRepo.Setup(r => r.GetByEmailAsync("student@fschool.edu.vn")).ReturnsAsync(user);

        var result = await _sut.ForgotPasswordAsync(new ForgotPasswordDto("student@fschool.edu.vn"));

        Assert.Equal(ForgotPasswordResult.EmailFailed, result);
        Assert.Null(user.PasswordResetCode);
        Assert.Null(user.PasswordResetCodeExpiresAt);
        _authRepo.Verify(r => r.SaveChangesAsync(), Times.Exactly(2));
    }

    [Fact]
    public async Task ResetPassword_InvalidCodeOrWeakPassword_DoesNotChangePassword()
    {
        var user = TestDataFactory.CreateUser(isActive: true);
        user.Email = "student@fschool.edu.vn";
        user.PasswordResetCode = "123456";
        user.PasswordResetCodeExpiresAt = DateTime.UtcNow.AddMinutes(5);
        _authRepo.Setup(r => r.GetByEmailAsync("student@fschool.edu.vn")).ReturnsAsync(user);

        var wrongCode = await _sut.ResetPasswordAsync(new ResetPasswordDto("student@fschool.edu.vn", "999999", "newpassword"));
        var weak = await _sut.ResetPasswordAsync(new ResetPasswordDto("student@fschool.edu.vn", "123456", "short"));

        Assert.Equal(ResetPasswordResult.InvalidOrExpired, wrongCode);
        Assert.Equal(ResetPasswordResult.InvalidOrExpired, weak);
        Assert.True(BCrypt.Net.BCrypt.Verify(TestDataFactory.DefaultPassword, user.PasswordHash));
        _authRepo.Verify(r => r.SaveChangesAsync(), Times.Never);
    }

    [Fact]
    public async Task ResetPassword_ValidCode_ChangesPasswordClearsOtpAndRevokesTokens()
    {
        var user = TestDataFactory.CreateUser(isActive: true);
        user.Email = "student@fschool.edu.vn";
        user.PasswordResetCode = "123456";
        user.PasswordResetCodeExpiresAt = DateTime.UtcNow.AddMinutes(5);
        _authRepo.Setup(r => r.GetByEmailAsync("student@fschool.edu.vn")).ReturnsAsync(user);

        var result = await _sut.ResetPasswordAsync(new ResetPasswordDto(" Student@Fschool.edu.vn ", "123456", "newpassword"));

        Assert.Equal(ResetPasswordResult.Success, result);
        Assert.True(BCrypt.Net.BCrypt.Verify("newpassword", user.PasswordHash));
        Assert.Null(user.PasswordResetCode);
        Assert.Null(user.PasswordResetCodeExpiresAt);
        _authRepo.Verify(r => r.RevokeAllRefreshTokensAsync(user.UserId), Times.Once);
        _authRepo.Verify(r => r.SaveChangesAsync(), Times.Once);
    }
}
