namespace PRM393API.DTOs;

public record LoginRequestDto(string PhoneNumber, string Password);

public record RefreshRequestDto(string RefreshToken);

public record ForgotPasswordDto(string Email);

public record ResetPasswordDto(string Email, string Code, string NewPassword);

public record AuthTokenDto(string AccessToken, string RefreshToken, UserDto User);

public enum LoginFailureReason
{
    None,
    InvalidCredentials,
    AccountLocked,
}

public record LoginResultDto(AuthTokenDto? Token, LoginFailureReason Failure = LoginFailureReason.None);

public enum ForgotPasswordResult
{
    Success,
    EmailFailed,
}

public enum ResetPasswordResult
{
    Success,
    InvalidOrExpired,
}
