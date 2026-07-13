using PRM393API.DTOs;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Integration;

/// <summary>E2E-1 · Admin: năm học → lớp → phân công → template → sinh TKB → phân lớp → link PH–HS.</summary>
public class MasterDataE2EIntegrationTests : IDisposable
{
    private readonly IntegrationServiceProvider _ctx = new(IntegrationSeedMode.Minimal);

    public void Dispose() => _ctx.Dispose();

    [Fact]
    public async Task E2E_1_FullMasterDataChain_ConfiguresSchoolForOperations()
    {
        var year = await _ctx.AcademicYear.CreateAsync(new CreateAcademicYearDto(
            "2025-2026", new DateOnly(2025, 9, 1), new DateOnly(2026, 5, 31), true));
        var semester = (await _ctx.Semester.GetByAcademicYearAsync(year.AcademicYearId)).First(s => s.SemesterName == "Học kỳ 1");

        await _ctx.TimetableSlot.CreateAsync(new CreateTimetableSlotDto(
            "Tiết 1", new TimeOnly(7, 0), new TimeOnly(7, 45)));

        var math = await _ctx.Subject.CreateAsync(new CreateSubjectDto("MATH", "Toán"));
        var cls = await _ctx.Class.CreateAsync(new CreateClassDto(
            "10A1", year.AcademicYearId, IntegrationScenarioSeed.Teacher01Id));

        var assignment = await _ctx.TeachingAssignment.CreateAsync(new CreateTeachingAssignmentDto(
            IntegrationScenarioSeed.Teacher01Id, cls.ClassId, math.SubjectId, semester.SemesterId));

        await _ctx.Timetable.CreateTemplateAsync(new CreateTimetableTemplateDto(
            assignment.TeachingAssignmentId, 2, 1, "Phòng 101"));

        var generated = await _ctx.Timetable.GenerateFromTemplatesAsync(semester.SemesterId, cls.ClassId);
        Assert.True(generated > 0);

        await _ctx.StudentClass.CreateAsync(new CreateStudentClassDto(
            IntegrationScenarioSeed.Student01Id, cls.ClassId));

        var link = await _ctx.ParentStudent.CreateAsync(new CreateParentStudentDto(
            IntegrationScenarioSeed.Parent01Id,
            IntegrationScenarioSeed.Student01Id,
            "Cha"));

        var testDate = new DateOnly(2025, 10, 6);
        var studentTt = await _ctx.Timetable.GetWeeklyByStudentAsync(
            IntegrationScenarioSeed.Student01Id, testDate);
        var teacherTt = (await _ctx.Timetable.GetWeeklyByTeacherAsync(
            IntegrationScenarioSeed.Teacher01Id, testDate)).ToList();

        Assert.NotNull(studentTt);
        Assert.Equal("10A1", studentTt!.Enrollment!.ClassName);
        Assert.NotEmpty(studentTt.Slots);
        Assert.NotEmpty(teacherTt);
        Assert.Equal("Cha", link.Relationship);

        var enrollment = await _ctx.AcademicContext.ResolveStudentEnrollmentAsync(
            IntegrationScenarioSeed.Student01Id, testDate);
        Assert.NotNull(enrollment);
        Assert.Equal(cls.ClassId, enrollment!.ClassId);
    }
}
