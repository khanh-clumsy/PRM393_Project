using Microsoft.AspNetCore.Mvc;
using Moq;
using PRM393API.Controllers;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;

namespace PRM393API.Tests.Controllers;

public class AuthControllerTests
{
    private readonly Mock<IAuthService> _service = new();
    private readonly AuthController _sut;

    public AuthControllerTests()
    {
        _sut = new AuthController(_service.Object);
    }

    [Fact]
    public async Task Login_AccountLocked_Returns403()
    {
        _service.Setup(s => s.LoginAsync(It.IsAny<LoginRequestDto>()))
            .ReturnsAsync(new LoginResultDto(null, LoginFailureReason.AccountLocked));

        var response = await _sut.Login(new LoginRequestDto("0901000006", "12345678"));

        var status = Assert.IsType<ObjectResult>(response);
        Assert.Equal(403, status.StatusCode);
    }

    [Fact]
    public async Task Login_InvalidCredentials_Returns401()
    {
        _service.Setup(s => s.LoginAsync(It.IsAny<LoginRequestDto>()))
            .ReturnsAsync(new LoginResultDto(null, LoginFailureReason.InvalidCredentials));

        var response = await _sut.Login(new LoginRequestDto("0901000006", "wrong"));

        Assert.IsType<UnauthorizedObjectResult>(response);
    }

    [Fact]
    public async Task Login_Success_Returns200WithToken()
    {
        var token = new AuthTokenDto(
            "access-token",
            "refresh-token",
            new UserDto(1, "student01", "HS Test", "student01@fschool.edu.vn", "0901000006", 4, "Student", null, null, null, null, null, true, DateTime.UtcNow));

        _service.Setup(s => s.LoginAsync(It.IsAny<LoginRequestDto>()))
            .ReturnsAsync(new LoginResultDto(token));

        var response = await _sut.Login(new LoginRequestDto("0901000006", "12345678"));

        var ok = Assert.IsType<OkObjectResult>(response);
        Assert.Same(token, ok.Value);
    }

    [Fact]
    public async Task Refresh_InvalidToken_Returns401()
    {
        _service.Setup(s => s.RefreshAsync(It.IsAny<RefreshRequestDto>()))
            .ReturnsAsync((AuthTokenDto?)null);

        var response = await _sut.Refresh(new RefreshRequestDto("bad-token"));

        Assert.IsType<UnauthorizedObjectResult>(response);
    }

    [Fact]
    public async Task ForgotPassword_EmailFailed_Returns503()
    {
        _service.Setup(s => s.ForgotPasswordAsync(It.IsAny<ForgotPasswordDto>()))
            .ReturnsAsync(ForgotPasswordResult.EmailFailed);

        var response = await _sut.ForgotPassword(new ForgotPasswordDto("student@fschool.edu.vn"));

        var result = Assert.IsType<ObjectResult>(response);
        Assert.Equal(503, result.StatusCode);
    }

    [Fact]
    public async Task ForgotPassword_Success_Returns200()
    {
        _service.Setup(s => s.ForgotPasswordAsync(It.IsAny<ForgotPasswordDto>()))
            .ReturnsAsync(ForgotPasswordResult.Success);

        var response = await _sut.ForgotPassword(new ForgotPasswordDto("student@fschool.edu.vn"));

        Assert.IsType<OkObjectResult>(response);
    }

    [Fact]
    public async Task ResetPassword_InvalidOrExpired_Returns400()
    {
        _service.Setup(s => s.ResetPasswordAsync(It.IsAny<ResetPasswordDto>()))
            .ReturnsAsync(ResetPasswordResult.InvalidOrExpired);

        var response = await _sut.ResetPassword(new ResetPasswordDto("student@fschool.edu.vn", "000000", "newpassword"));

        Assert.IsType<BadRequestObjectResult>(response);
    }

    [Fact]
    public async Task ResetPassword_Success_Returns200()
    {
        _service.Setup(s => s.ResetPasswordAsync(It.IsAny<ResetPasswordDto>()))
            .ReturnsAsync(ResetPasswordResult.Success);

        var response = await _sut.ResetPassword(new ResetPasswordDto("student@fschool.edu.vn", "123456", "newpassword"));

        Assert.IsType<OkObjectResult>(response);
    }
}
