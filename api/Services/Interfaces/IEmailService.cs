namespace PRM393API.Services.Interfaces;

public interface IEmailService
{
    // Gửi email chứa OTP đặt lại mật khẩu.
    Task SendPasswordResetCodeAsync(string toEmail, string code);
}
