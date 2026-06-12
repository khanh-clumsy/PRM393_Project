using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(IAuthService service) : ControllerBase
{
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequestDto dto)
    {
        var result = await service.LoginAsync(dto);
        return result is null ? Unauthorized(new { message = "Tên đăng nhập hoặc mật khẩu không đúng." }) : Ok(result);
    }

    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh([FromBody] RefreshRequestDto dto)
    {
        var result = await service.RefreshAsync(dto);
        return result is null ? Unauthorized(new { message = "Refresh token không hợp lệ hoặc đã hết hạn." }) : Ok(result);
    }

    [HttpPost("forgot-password")]
    public IActionResult ForgotPassword([FromBody] ForgotPasswordDto dto) =>
        Ok(new { message = "Nếu email tồn tại, link đặt lại mật khẩu đã được gửi." });
}
