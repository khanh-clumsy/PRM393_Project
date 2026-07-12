using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class AcademicRankServiceTests
{
    private readonly Mock<IAcademicRankRepository> _repo = new();
    private readonly AcademicRankService _sut;

    public AcademicRankServiceTests() => _sut = new AcademicRankService(_repo.Object);

    private static AcademicRank Sample() => new()
    {
        RankId = 1,
        RankName = "Giỏi",
        MinScore = 8.0m,
        MaxScore = 10.0m,
    };

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        Assert.Equal("Giỏi", (await _sut.GetByIdAsync(1))!.RankName);
    }

    [Fact]
    public async Task CreateAsync_MapsScoreRange()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<AcademicRank>()))
            .ReturnsAsync((AcademicRank a) => { a.RankId = 2; return a; });
        var result = await _sut.CreateAsync(new CreateAcademicRankDto("Khá", 6.5m, 7.9m));
        Assert.Equal(6.5m, result.MinScore);
    }

    [Fact]
    public async Task UpdateAsync_Existing_UpdatesName()
    {
        var existing = Sample();
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.UpdateAsync(1, It.IsAny<AcademicRank>()))
            .ReturnsAsync((int _, AcademicRank a) => a);
        var result = await _sut.UpdateAsync(1, new UpdateAcademicRankDto("Giỏi+", null, null));
        Assert.Equal("Giỏi+", result!.RankName);
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
