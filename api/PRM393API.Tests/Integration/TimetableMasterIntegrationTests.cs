using PRM393API.DTOs;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Integration;

/// <summary>TC-A05 · Thời khóa biểu quản lý (template → sinh lịch).</summary>
public class TimetableMasterIntegrationTests : IDisposable
{
    private readonly IntegrationServiceProvider _ctx = new();

    public void Dispose() => _ctx.Dispose();

    [Fact]
    public async Task TC_A05_CreateTemplate_ThenGenerateFromTemplates()
    {
        await _ctx.Timetable.CreateTemplateAsync(new CreateTimetableTemplateDto(
            IntegrationScenarioSeed.TeachingAssignmentMath10A1, 2, 2, "Phòng 102"));

        var count = await _ctx.Timetable.GenerateFromTemplatesAsync(
            IntegrationScenarioSeed.SemesterHk1Id,
            IntegrationScenarioSeed.Class10A1Id);

        Assert.True(count > 0);

        var templates = (await _ctx.Timetable.GetTemplatesByClassAsync(
            IntegrationScenarioSeed.Class10A1Id,
            IntegrationScenarioSeed.SemesterHk1Id)).ToList();
        Assert.NotEmpty(templates);
    }

    [Fact]
    public async Task TC_A05_DuplicateTemplateSameAssignmentSlot_Throws()
    {
        await _ctx.Timetable.CreateTemplateAsync(new CreateTimetableTemplateDto(
            IntegrationScenarioSeed.TeachingAssignmentMath10A1, 2, 1, "P101"));

        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _ctx.Timetable.CreateTemplateAsync(new CreateTimetableTemplateDto(
                IntegrationScenarioSeed.TeachingAssignmentMath10A1, 2, 1, "P102")));

        Assert.Contains("trùng", ex.Message);
    }

    [Fact]
    public async Task TC_A05_CreateTimetable_TeacherConflict_Throws()
    {
        var secondTa = await _ctx.TeachingAssignment.CreateAsync(new CreateTeachingAssignmentDto(
            IntegrationScenarioSeed.Teacher01Id,
            IntegrationScenarioSeed.Class10A2Id,
            1,
            IntegrationScenarioSeed.SemesterHk1Id));

        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _ctx.Timetable.CreateAsync(new CreateTimetableDto(
                secondTa.TeachingAssignmentId,
                IntegrationScenarioSeed.TestDate,
                1,
                "P201",
                1)));

        Assert.Contains("Giáo viên", ex.Message);
    }

    [Fact]
    public async Task TC_A05_UpdateTimetableStatus_Persists()
    {
        var updated = await _ctx.Timetable.UpdateAsync(1, new UpdateTimetableDto(
            null, null, null, 3, "Nghỉ học"));

        Assert.NotNull(updated);
        Assert.Equal((byte)3, updated!.Status);
        Assert.Equal("Nghỉ học", updated.Note);
    }

    [Fact]
    public async Task TC_A05_ClearGeneratedTimetables_RemovesSlotsAndAttendance()
    {
        await _ctx.Attendance.BulkCreateAsync(new[]
        {
            new CreateAttendanceDto(1, IntegrationScenarioSeed.Student01Id, "Present", null, IntegrationScenarioSeed.Teacher01Id),
        });

        var removed = await _ctx.Timetable.ClearGeneratedTimetablesAsync(
            IntegrationScenarioSeed.SemesterHk1Id,
            IntegrationScenarioSeed.Class10A1Id);

        Assert.True(removed >= 1);
        Assert.Empty(await _ctx.Attendance.GetByTimetableAsync(1));
    }
}
