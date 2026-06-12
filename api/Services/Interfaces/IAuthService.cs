using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IAuthService
{
    Task<AuthTokenDto?> LoginAsync(LoginRequestDto dto);
    Task<AuthTokenDto?> RefreshAsync(RefreshRequestDto dto);
}
