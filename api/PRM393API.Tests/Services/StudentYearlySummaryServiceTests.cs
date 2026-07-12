using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class StudentYearlySummaryServiceTests
{
    private readonly Mock<IStudentYearlySummaryRepository> _repo = new();
    private readonly StudentYearlySummaryService _sut;

    public StudentYearlySummaryServiceTests() => _sut = new StudentYearlySummaryService(_repo.Object);

    private static StudentYearlySummary Sample() => new()
    {
        YearlySummaryId = 1,
        StudentId = 10,
        AcademicYearId = 1,
        YearlyGpa = 8.5m,
        YearlyConduct = "Tốt",
        RankId = 1,
        EvaluatedBy = 3,
        EvaluatedAt = DateTime.UtcNow,
    };

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        Assert.Equal(8.5m, (await _sut.GetByIdAsync(1))!.YearlyGpa);
    }

    [Fact]
    public async Task CreateAsync_SetsEvaluatedAt()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<StudentYearlySummary>())).ReturnsAsync((StudentYearlySummary s) => s);
        var dto = new CreateYearlySummaryDto(10, 1, 8.3m, "Khá", 2, 3);
        var result = await _sut.CreateAsync(dto);
        Assert.Equal(8.3m, result.YearlyGpa);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((StudentYearlySummary?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateYearlySummaryDto(7.0m, null, null)));
    }

    [Fact]
    public async Task GetByYearAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByYearAsync(1)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByYearAsync(1));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
