using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class AssessmentServiceTests
{
    private readonly Mock<IAssessmentRepository> _repo = new();
    private readonly AssessmentService _sut;

    public AssessmentServiceTests() => _sut = new AssessmentService(_repo.Object);

    private static Assessment Sample() => new()
    {
        AssessmentId = 1,
        TeachingAssignmentId = 1,
        AssessmentTypeId = 1,
        AssessmentName = "KT GK1",
        AssessmentDate = new DateOnly(2025, 10, 15),
        MaxScore = 10m,
    };

    [Fact]
    public async Task CreateAsync_MapsFields()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<Assessment>())).ReturnsAsync((Assessment a) => a);
        var dto = new CreateAssessmentDto(1, 1, "KT CK1", new DateOnly(2025, 12, 20), 10m);
        var result = await _sut.CreateAsync(dto);
        Assert.Equal("KT CK1", result.AssessmentName);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Assessment?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateAssessmentDto("X", null, null)));
    }

    [Fact]
    public async Task GetByTeachingAssignmentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByTeachingAssignmentAsync(1)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByTeachingAssignmentAsync(1));
    }

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        Assert.Equal("KT GK1", (await _sut.GetByIdAsync(1))!.AssessmentName);
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
