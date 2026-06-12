namespace PRM393API.DTOs;

public record LoginRequestDto(string PhoneNumber, string Password);

public record RefreshRequestDto(string RefreshToken);

public record ForgotPasswordDto(string Email);

public record AuthTokenDto(string AccessToken, string RefreshToken, UserDto User);
