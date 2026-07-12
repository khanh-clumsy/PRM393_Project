using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class AssessmentTypeServiceTests
{
    private readonly Mock<IAssessmentTypeRepository> _repo = new();
    private readonly AssessmentTypeService _sut;

    public AssessmentTypeServiceTests() => _sut = new AssessmentTypeService(_repo.Object);

    private static AssessmentType Sample() => new()
    {
        AssessmentTypeId = 1,
        TypeName = "Giữa kỳ",
        Weight = 0.3m,
    };

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        Assert.Equal("Giữa kỳ", (await _sut.GetByIdAsync(1))!.TypeName);
    }

    [Fact]
    public async Task CreateAsync_MapsWeight()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<AssessmentType>())).ReturnsAsync((AssessmentType t) => t);
        var result = await _sut.CreateAsync(new CreateAssessmentTypeDto("Cuối kỳ", 0.7m));
        Assert.Equal(0.7m, result.Weight);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((AssessmentType?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateAssessmentTypeDto("X", null)));
    }

    [Fact]
    public async Task GetAllAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetAllAsync());
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
