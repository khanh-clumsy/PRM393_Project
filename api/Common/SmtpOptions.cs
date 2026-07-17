namespace PRM393API.Common;

// Cấu hình SMTP đọc từ section "Smtp"; secret nạp qua env/User Secrets.
public class SmtpOptions
{
    public string Host { get; set; } = "";
    public int Port { get; set; } = 587;
    public string Username { get; set; } = "";
    public string Password { get; set; } = "";
    public string FromEmail { get; set; } = "";
    public string FromName { get; set; } = "FSchool";
    public bool EnableSsl { get; set; } = true;
}
