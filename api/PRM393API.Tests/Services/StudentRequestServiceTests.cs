using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class StudentRequestServiceTests
{
    private readonly Mock<IStudentRequestRepository> _repo = new();
    private readonly StudentRequestService _sut;

    public StudentRequestServiceTests() => _sut = new StudentRequestService(_repo.Object);

    private static StudentRequest Sample() => new()
    {
        StudentRequestId = 1,
        StudentId = 10,
        RequestedBy = 10,
        LeaveDate = new DateOnly(2025, 11, 1),
        Reason = "ốm",
        Status = "Pending",
        CreatedAt = DateTime.UtcNow,
    };

    [Fact]
    public async Task CreateAsync_DefaultStatusPending()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<StudentRequest>())).ReturnsAsync((StudentRequest r) => r);
        var dto = new CreateStudentRequestDto(10, 10, new DateOnly(2025, 11, 2), "việc gia đình", null);
        var result = await _sut.CreateAsync(dto);
        _repo.Verify(r => r.CreateAsync(It.Is<StudentRequest>(x => x.Status == "Pending")), Times.Once);
        Assert.Equal("việc gia đình", result.Reason);
    }

    [Fact]
    public async Task ReviewAsync_Approved_SetsReviewedAt()
    {
        var existing = Sample();
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.ReviewAsync(1, It.IsAny<StudentRequest>())).ReturnsAsync((int _, StudentRequest r) => r);
        var result = await _sut.ReviewAsync(1, new ReviewStudentRequestDto("Approved", 3, "OK"));
        Assert.Equal("Approved", result!.Status);
        Assert.NotNull(result.ReviewedAt);
    }

    [Fact]
    public async Task ReviewAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((StudentRequest?)null);
        Assert.Null(await _sut.ReviewAsync(99, new ReviewStudentRequestDto("Rejected", 3, "Không hợp lệ")));
    }

    [Fact]
    public async Task GetPendingAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetPendingAsync()).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetPendingAsync());
    }

    [Fact]
    public async Task GetByStudentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByStudentAsync(10)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByStudentAsync(10));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
