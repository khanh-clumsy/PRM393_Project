using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IAuthService
{
    Task<LoginResultDto> LoginAsync(LoginRequestDto dto);
    Task<AuthTokenDto?> RefreshAsync(RefreshRequestDto dto);
    Task<ForgotPasswordResult> ForgotPasswordAsync(ForgotPasswordDto dto);
    Task<ResetPasswordResult> ResetPasswordAsync(ResetPasswordDto dto);
}
