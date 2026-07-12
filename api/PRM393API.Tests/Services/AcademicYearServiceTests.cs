using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class AcademicYearServiceTests
{
    private readonly Mock<IAcademicYearRepository> _yearRepo = new();
    private readonly Mock<ISemesterRepository> _semesterRepo = new();
    private readonly AcademicYearService _sut;

    public AcademicYearServiceTests()
    {
        _sut = new AcademicYearService(_yearRepo.Object, _semesterRepo.Object);
    }

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        var year = TestDataFactory.CreateAcademicYear();
        _yearRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(year);

        var result = await _sut.GetByIdAsync(1);

        Assert.NotNull(result);
        Assert.Equal("2025-2026", result!.YearName);
    }

    [Fact]
    public async Task GetByIdAsync_NotFound_ReturnsNull()
    {
        _yearRepo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((AcademicYear?)null);
        Assert.Null(await _sut.GetByIdAsync(99));
    }

    [Fact]
    public async Task CreateAsync_AutoCreatesTwoSemesters()
    {
        var dto = new CreateAcademicYearDto("2026-2027", new DateOnly(2026, 9, 1), new DateOnly(2027, 5, 31), true);
        _yearRepo.Setup(r => r.CreateAsync(It.IsAny<AcademicYear>()))
            .ReturnsAsync((AcademicYear y) => { y.AcademicYearId = 2; return y; });
        _semesterRepo.Setup(r => r.CreateAsync(It.IsAny<Semester>()))
            .ReturnsAsync((Semester s) => s);

        var result = await _sut.CreateAsync(dto);

        Assert.Equal("2026-2027", result.YearName);
        _semesterRepo.Verify(r => r.CreateAsync(It.Is<Semester>(s => s.SemesterName == "Học kỳ 1")), Times.Once);
        _semesterRepo.Verify(r => r.CreateAsync(It.Is<Semester>(s => s.SemesterName == "Học kỳ 2")), Times.Once);
    }

    [Fact]
    public async Task CreateAsync_SemesterDatesMatchBusinessRule()
    {
        var dto = new CreateAcademicYearDto("2025-2026", new DateOnly(2025, 9, 1), new DateOnly(2026, 5, 31));
        _yearRepo.Setup(r => r.CreateAsync(It.IsAny<AcademicYear>()))
            .ReturnsAsync((AcademicYear y) => { y.AcademicYearId = 1; return y; });

        Semester? sem1 = null;
        Semester? sem2 = null;
        _semesterRepo.Setup(r => r.CreateAsync(It.IsAny<Semester>()))
            .Callback<Semester>(s => { if (sem1 is null) sem1 = s; else sem2 = s; })
            .ReturnsAsync((Semester s) => s);

        await _sut.CreateAsync(dto);

        Assert.NotNull(sem1);
        Assert.NotNull(sem2);
        Assert.Equal(new DateOnly(2025, 9, 1), sem1!.StartDate);
        Assert.Equal(new DateOnly(2026, 1, 15), sem1.EndDate);
        Assert.Equal(new DateOnly(2026, 1, 16), sem2!.StartDate);
        Assert.Equal(new DateOnly(2026, 5, 31), sem2.EndDate);
    }

    [Fact]
    public async Task UpdateAsync_Existing_UpdatesFields()
    {
        var existing = TestDataFactory.CreateAcademicYear();
        _yearRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _yearRepo.Setup(r => r.UpdateAsync(1, It.IsAny<AcademicYear>()))
            .ReturnsAsync((int _, AcademicYear y) => y);

        var result = await _sut.UpdateAsync(1, new UpdateAcademicYearDto("2025-2026 (sửa)", null, null, false));

        Assert.NotNull(result);
        Assert.Equal("2025-2026 (sửa)", result!.YearName);
        Assert.False(result.IsActive);
    }

    [Fact]
    public async Task DeleteAsync_DelegatesToRepo()
    {
        _yearRepo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
