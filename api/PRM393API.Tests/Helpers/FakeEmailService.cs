using PRM393API.Services.Interfaces;

namespace PRM393API.Tests.Helpers;

internal sealed class FakeEmailService : IEmailService
{
    public bool ShouldThrow { get; set; }
    public string? LastToEmail { get; private set; }
    public string? LastCode { get; private set; }
    public int SendCount { get; private set; }

    public Task SendPasswordResetCodeAsync(string toEmail, string code)
    {
        SendCount++;
        if (ShouldThrow)
            throw new InvalidOperationException("SMTP loi gia lap.");

        LastToEmail = toEmail;
        LastCode = code;
        return Task.CompletedTask;
    }
}
