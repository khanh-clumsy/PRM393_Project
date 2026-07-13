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
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(Array.Empty<AcademicRank>());
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
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[] { existing });
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
    public async Task CreateAsync_NegativeScore_Throws()
    {
        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _sut.CreateAsync(new CreateAcademicRankDto("Yếu", -1m, 3m)));
        _repo.Verify(r => r.CreateAsync(It.IsAny<AcademicRank>()), Times.Never);
    }

    [Fact]
    public async Task CreateAsync_MinGreaterThanMax_Throws()
    {
        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _sut.CreateAsync(new CreateAcademicRankDto("Khá", 8m, 6m)));
    }

    [Fact]
    public async Task CreateAsync_OverlappingRange_Throws()
    {
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[]
        {
            new AcademicRank { RankId = 5, RankName = "Kém", MinScore = 0.0m, MaxScore = 3.49m },
        });

        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _sut.CreateAsync(new CreateAcademicRankDto("Siêu kém", 1.0m, 3.0m)));

        Assert.Contains("Kém", ex.Message);
        _repo.Verify(r => r.CreateAsync(It.IsAny<AcademicRank>()), Times.Never);
    }

    [Fact]
    public async Task UpdateAsync_OverlappingOtherRank_Throws()
    {
        _repo.Setup(r => r.GetByIdAsync(2)).ReturnsAsync(new AcademicRank
        {
            RankId = 2,
            RankName = "Khá",
            MinScore = 6.5m,
            MaxScore = 7.99m,
        });
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[]
        {
            new AcademicRank { RankId = 2, RankName = "Khá", MinScore = 6.5m, MaxScore = 7.99m },
            new AcademicRank { RankId = 3, RankName = "Trung Bình", MinScore = 5.0m, MaxScore = 6.49m },
        });

        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _sut.UpdateAsync(2, new UpdateAcademicRankDto(null, 6.0m, 7.0m)));

        _repo.Verify(r => r.UpdateAsync(It.IsAny<int>(), It.IsAny<AcademicRank>()), Times.Never);
    }

    [Fact]
    public async Task CreateAsync_AdjacentNonOverlappingRange_Succeeds()
    {
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[]
        {
            new AcademicRank { RankId = 5, RankName = "Kém", MinScore = 0.0m, MaxScore = 3.49m },
        });
        _repo.Setup(r => r.CreateAsync(It.IsAny<AcademicRank>()))
            .ReturnsAsync((AcademicRank a) => { a.RankId = 6; return a; });

        var result = await _sut.CreateAsync(new CreateAcademicRankDto("Yếu", 3.5m, 4.99m));

        Assert.Equal(3.5m, result.MinScore);
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
