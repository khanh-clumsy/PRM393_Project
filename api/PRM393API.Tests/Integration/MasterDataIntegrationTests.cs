using PRM393API.DTOs;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Integration;

/// <summary>TC-A03 · Chuỗi master data cơ bản.</summary>
public class MasterDataIntegrationTests : IDisposable
{
    private readonly IntegrationServiceProvider _ctx = new(IntegrationSeedMode.Minimal);

    public void Dispose() => _ctx.Dispose();

    [Fact]
    public async Task TC_A03_CreateAcademicYear_AutoCreatesTwoSemesters()
    {
        var year = await _ctx.AcademicYear.CreateAsync(new CreateAcademicYearDto(
            "2026-2027",
            new DateOnly(2026, 9, 1),
            new DateOnly(2027, 5, 31),
            true));

        var semesters = (await _ctx.Semester.GetByAcademicYearAsync(year.AcademicYearId)).ToList();

        Assert.Equal(2, semesters.Count);
        Assert.Contains(semesters, s => s.SemesterName == "Học kỳ 1");
        Assert.Contains(semesters, s => s.SemesterName == "Học kỳ 2");
    }

    [Fact]
    public async Task TC_A03_AcademicYears_SortedByStartDate()
    {
        await _ctx.AcademicYear.CreateAsync(new CreateAcademicYearDto(
            "2027-2028", new DateOnly(2027, 9, 1), new DateOnly(2028, 5, 31)));
        await _ctx.AcademicYear.CreateAsync(new CreateAcademicYearDto(
            "2025-2026", new DateOnly(2025, 9, 1), new DateOnly(2026, 5, 31)));

        var years = (await _ctx.AcademicYear.GetAllAsync()).ToList();

        Assert.True(years.Count >= 2);
        Assert.True(years.SequenceEqual(years.OrderBy(y => y.StartDate)));
    }

    [Fact]
    public async Task TC_A03_CreateClass_DuplicateNameInYear_Throws()
    {
        var year = await _ctx.AcademicYear.CreateAsync(new CreateAcademicYearDto(
            "2025-2026", new DateOnly(2025, 9, 1), new DateOnly(2026, 5, 31)));
        await _ctx.Class.CreateAsync(new CreateClassDto("10A1", year.AcademicYearId, IntegrationScenarioSeed.Teacher01Id));

        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _ctx.Class.CreateAsync(new CreateClassDto("10a1", year.AcademicYearId, null)));

        Assert.Contains("đã tồn tại", ex.Message);
    }

    [Fact]
    public async Task TC_A03_CreateClass_HomeroomTeacherAlreadyAssigned_Throws()
    {
        var year = await _ctx.AcademicYear.CreateAsync(new CreateAcademicYearDto(
            "2025-2026", new DateOnly(2025, 9, 1), new DateOnly(2026, 5, 31)));
        await _ctx.Class.CreateAsync(new CreateClassDto("10A1", year.AcademicYearId, IntegrationScenarioSeed.Teacher01Id));

        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _ctx.Class.CreateAsync(new CreateClassDto("10A2", year.AcademicYearId, IntegrationScenarioSeed.Teacher01Id)));

        Assert.Contains("chủ nhiệm", ex.Message);
    }

    [Fact]
    public async Task TC_A03_CreateSubject_AndToggleIsActive()
    {
        var subject = await _ctx.Subject.CreateAsync(new CreateSubjectDto("PHY", "Vật lý", true));
        Assert.True(subject.IsActive);

        var updated = await _ctx.Subject.UpdateAsync(subject.SubjectId, new UpdateSubjectDto(null, null, false));
        Assert.NotNull(updated);
        Assert.False(updated!.IsActive);
    }

    [Fact]
    public async Task TC_A03_CreateTimetableSlot_Persists()
    {
        var slot = await _ctx.TimetableSlot.CreateAsync(new CreateTimetableSlotDto(
            "Tiết 3", new TimeOnly(8, 40), new TimeOnly(9, 25)));

        Assert.Equal("Tiết 3", slot.SlotName);
        Assert.Equal(new TimeOnly(8, 40), slot.StartTime);
    }

    [Fact]
    public async Task TC_A03_CreateAcademicRank_OverlappingRange_Throws()
    {
        await _ctx.AcademicRank.CreateAsync(new CreateAcademicRankDto("Giỏi", 8.0m, 10.0m));

        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _ctx.AcademicRank.CreateAsync(new CreateAcademicRankDto("Xuất sắc", 9.0m, 10.0m)));

        Assert.Contains("trùng", ex.Message);
    }

    [Fact]
    public async Task TC_A03_CreateAcademicRank_InvalidRange_Throws()
    {
        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _ctx.AcademicRank.CreateAsync(new CreateAcademicRankDto("Lỗi", 9.0m, 5.0m)));

        Assert.Contains("lớn hơn", ex.Message);
    }
}
