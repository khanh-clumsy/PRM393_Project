using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class SubmissionServiceTests
{
    private readonly Mock<ISubmissionRepository> _repo = new();
    private readonly SubmissionService _sut;

    public SubmissionServiceTests() => _sut = new SubmissionService(_repo.Object);

    private static Submission Sample() => new()
    {
        SubmissionId = 1,
        AssignmentId = 1,
        StudentId = 10,
        ContentText = "Bài làm",
        SubmittedAt = DateTime.UtcNow,
    };

    [Fact]
    public async Task CreateAsync_SetsSubmittedAt()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<Submission>())).ReturnsAsync((Submission s) => s);
        var result = await _sut.CreateAsync(new CreateSubmissionDto(1, 10, "Nộp bài", null, null));
        Assert.Equal("Nộp bài", result.ContentText);
        _repo.Verify(r => r.CreateAsync(It.Is<Submission>(s => s.SubmittedAt <= DateTime.UtcNow)), Times.Once);
    }

    [Fact]
    public async Task GradeAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Submission?)null);
        Assert.Null(await _sut.GradeAsync(99, new GradeSubmissionDto(8.0m, "OK", 3)));
    }

    [Fact]
    public async Task GradeAsync_SetsScoreAndFeedback()
    {
        var existing = Sample();
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.GradeAsync(1, It.IsAny<Submission>())).ReturnsAsync((int _, Submission s) => s);
        var result = await _sut.GradeAsync(1, new GradeSubmissionDto(8.5m, "Khá", 3));
        Assert.NotNull(result);
        Assert.Equal(8.5m, result!.Score);
    }

    [Fact]
    public async Task GetByAssignmentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByAssignmentAsync(1)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByAssignmentAsync(1));
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
