using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Options;
using PRM393API.Common;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class SmtpEmailService(IOptions<SmtpOptions> options) : IEmailService
{
    private readonly SmtpOptions _options = options.Value;

    public async Task SendPasswordResetCodeAsync(string toEmail, string code)
    {
        using var message = new MailMessage
        {
            From = new MailAddress(_options.FromEmail, _options.FromName),
            Subject = "Mã đặt lại mật khẩu FSchool",
            // Email không chứa mật khẩu, chỉ chứa OTP và thời hạn hiệu lực.
            Body = $"Mã đặt lại mật khẩu của bạn là: {code}\n" +
                   "Mã có hiệu lực trong 10 phút. Vui lòng không chia sẻ mã này.",
            IsBodyHtml = false,
        };
        message.To.Add(toEmail);

        using var client = new SmtpClient(_options.Host, _options.Port)
        {
            EnableSsl = _options.EnableSsl,
            Credentials = new NetworkCredential(_options.Username, _options.Password),
        };

        await client.SendMailAsync(message);
    }
}
