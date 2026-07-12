using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class NotificationLogServiceTests
{
    private readonly Mock<INotificationLogRepository> _repo = new();
    private readonly NotificationLogService _sut;

    public NotificationLogServiceTests() => _sut = new NotificationLogService(_repo.Object);

    private static NotificationLog Sample(bool isRead = false) => new()
    {
        NotificationId = 1,
        UserId = 10,
        AnnouncementId = 1,
        Title = "Thông báo mới",
        Body = "Nội dung",
        IsRead = isRead,
        CreatedAt = DateTime.UtcNow,
    };

    [Fact]
    public async Task CreateAsync_DefaultIsReadFalse()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<NotificationLog>())).ReturnsAsync((NotificationLog n) => n);
        var result = await _sut.CreateAsync(new CreateNotificationLogDto(10, 1, "Tiêu đề", "Body"));
        _repo.Verify(r => r.CreateAsync(It.Is<NotificationLog>(n => !n.IsRead)), Times.Once);
        Assert.Equal("Tiêu đề", result.Title);
    }

    [Fact]
    public async Task MarkReadAsync_Existing_ReturnsUpdatedDto()
    {
        var updated = Sample(isRead: true);
        updated.ReadAt = DateTime.UtcNow;
        _repo.Setup(r => r.MarkReadAsync(1)).ReturnsAsync(updated);
        var result = await _sut.MarkReadAsync(1);
        Assert.NotNull(result);
        Assert.True(result!.IsRead);
    }

    [Fact]
    public async Task MarkReadAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.MarkReadAsync(99)).ReturnsAsync((NotificationLog?)null);
        Assert.Null(await _sut.MarkReadAsync(99));
    }

    [Fact]
    public async Task GetUnreadByUserAsync_ReturnsOnlyUnread()
    {
        _repo.Setup(r => r.GetUnreadByUserAsync(10)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetUnreadByUserAsync(10));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
