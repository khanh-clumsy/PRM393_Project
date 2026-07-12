using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class SemesterServiceTests
{
    private readonly Mock<ISemesterRepository> _repo = new();
    private readonly SemesterService _sut;

    public SemesterServiceTests() => _sut = new SemesterService(_repo.Object);

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        var sem = TestDataFactory.CreateSemester();
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(sem);
        var result = await _sut.GetByIdAsync(1);
        Assert.NotNull(result);
        Assert.Equal("Học kỳ 1", result!.SemesterName);
    }

    [Fact]
    public async Task GetByAcademicYearAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByAcademicYearAsync(1))
            .ReturnsAsync(new[] { TestDataFactory.CreateSemester(), TestDataFactory.CreateSemester(id: 2) });
        Assert.Equal(2, (await _sut.GetByAcademicYearAsync(1)).Count());
    }

    [Fact]
    public async Task CreateAsync_MapsFields()
    {
        var dto = new CreateSemesterDto(1, "HK phụ", new DateOnly(2026, 6, 1), new DateOnly(2026, 7, 31));
        _repo.Setup(r => r.CreateAsync(It.IsAny<Semester>()))
            .ReturnsAsync((Semester s) => { s.SemesterId = 3; return s; });
        var result = await _sut.CreateAsync(dto);
        Assert.Equal("HK phụ", result.SemesterName);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Semester?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateSemesterDto("X", null, null)));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
