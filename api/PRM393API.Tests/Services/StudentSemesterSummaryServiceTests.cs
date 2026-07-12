using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class StudentSemesterSummaryServiceTests
{
    private readonly Mock<IStudentSemesterSummaryRepository> _repo = new();
    private readonly StudentSemesterSummaryService _sut;

    public StudentSemesterSummaryServiceTests() => _sut = new StudentSemesterSummaryService(_repo.Object);

    private static StudentSemesterSummary Sample() => new()
    {
        SummaryId = 1,
        StudentId = 10,
        SemesterId = 1,
        Gpa = 8.2m,
        Conduct = "Tốt",
        RankId = 1,
        EvaluatedBy = 3,
        EvaluatedAt = DateTime.UtcNow,
    };

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        var result = await _sut.GetByIdAsync(1);
        Assert.Equal(8.2m, result!.Gpa);
    }

    [Fact]
    public async Task CreateAsync_SetsEvaluatedAt()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<StudentSemesterSummary>())).ReturnsAsync((StudentSemesterSummary s) => s);
        var dto = new CreateSemesterSummaryDto(10, 1, 8.0m, "Khá", 2, 3);
        var result = await _sut.CreateAsync(dto);
        Assert.Equal(8.0m, result.Gpa);
        _repo.Verify(r => r.CreateAsync(It.Is<StudentSemesterSummary>(s => s.EvaluatedAt <= DateTime.UtcNow)), Times.Once);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((StudentSemesterSummary?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateSemesterSummaryDto(7.5m, null, null)));
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
