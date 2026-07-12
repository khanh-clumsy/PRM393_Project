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
    private readonly Mock<IUserRepository> _userRepo = new();
    private readonly AuthService _sut;

    public AuthServiceTests()
    {
        _sut = new AuthService(_authRepo.Object, _userRepo.Object, TestDataFactory.CreateJwtHelper());
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
}
