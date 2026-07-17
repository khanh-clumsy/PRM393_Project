using PRM393API.DTOs;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Integration;

/// <summary>
/// Integration tests map các luồng trong docs/tests/MOBILE_TEST_MATRIX.md.
/// Chạy service + repository thật trên InMemory DB.
/// </summary>
public class MobileTestMatrixIntegrationTests : IDisposable
{
    private readonly IntegrationServiceProvider _ctx = new();

    public void Dispose() => _ctx.Dispose();

    // ── §2 ADMIN ─────────────────────────────────────────────────────────────

    /// <summary>TC-A02 · Khóa / mở tài khoản</summary>
    [Fact]
    public async Task TC_A02_LockedUser_CannotLogin()
    {
        await _ctx.User.UpdateAsync(IntegrationScenarioSeed.Student01Id,
            new UpdateUserDto(null, null, null, null, null, null, false, null, null));

        var result = await _ctx.Auth.LoginAsync(new LoginRequestDto("0901000006", TestDataFactory.DefaultPassword));

        Assert.Null(result.Token);
        Assert.Equal(LoginFailureReason.AccountLocked, result.Failure);
    }

    /// <summary>TC-A07 · Phụ huynh – Học sinh</summary>
    [Fact]
    public async Task TC_A07_ParentStudentLink_ReturnsRelationship()
    {
        var links = (await _ctx.ParentStudent.GetByParentAsync(IntegrationScenarioSeed.Parent01Id)).ToList();

        Assert.Single(links);
        Assert.Equal(IntegrationScenarioSeed.Student01Id, links[0].StudentId);
        Assert.Equal("Cha", links[0].Relationship);
    }

    // ── §3 HEAD OF DEPT ──────────────────────────────────────────────────────

    /// <summary>TC-H03 · Giáo viên tổ</summary>
    [Fact]
    public async Task TC_H03_DepartmentTeachers_OnlyDeptMembers()
    {
        var teachers = (await _ctx.Department.GetTeachersAsync(IntegrationScenarioSeed.DeptVanId)).ToList();

        Assert.Contains(teachers, t => t.Id == IntegrationScenarioSeed.Teacher02Id);
        Assert.DoesNotContain(teachers, t => t.Id == IntegrationScenarioSeed.Teacher01Id);
    }

    /// <summary>TC-H04 · Phân công tổ</summary>
    [Fact]
    public async Task TC_H04_DepartmentAssignments_ScopedToDept()
    {
        var assignments = (await _ctx.Department.GetAssignmentsAsync(IntegrationScenarioSeed.DeptVanId)).ToList();

        Assert.All(assignments, a => Assert.Equal(IntegrationScenarioSeed.Teacher02Id, a.TeacherId));
        Assert.DoesNotContain(assignments, a => a.TeacherId == IntegrationScenarioSeed.Teacher01Id);
    }

    // ── §4 GIÁO VIÊN ────────────────────────────────────────────────────────

    /// <summary>TC-T01 · Thời khóa biểu giáo viên</summary>
    [Fact]
    public async Task TC_T01_TeacherWeeklyTimetable_ShowsAssignedClass()
    {
        var slots = (await _ctx.Timetable.GetWeeklyByTeacherAsync(
            IntegrationScenarioSeed.Teacher01Id,
            IntegrationScenarioSeed.TestDate)).ToList();

        Assert.NotEmpty(slots);
        Assert.All(slots, s => Assert.Equal("10A1", s.ClassName));
        Assert.Contains(slots, s => s.SubjectName == "Toán");
    }

    /// <summary>TC-T02 · Điểm danh full flow</summary>
    [Fact]
    public async Task TC_T02_AttendanceBulkCreate_PersistsOnReload()
    {
        const int timetableId = 1;
        var dtos = new[]
        {
            new CreateAttendanceDto(timetableId, IntegrationScenarioSeed.Student01Id, "Present", null, IntegrationScenarioSeed.Teacher01Id),
            new CreateAttendanceDto(timetableId, IntegrationScenarioSeed.Student02Id, "Absent", "ốm", IntegrationScenarioSeed.Teacher01Id),
        };

        var created = (await _ctx.Attendance.BulkCreateAsync(dtos)).ToList();
        Assert.Equal(2, created.Count);
        Assert.Equal("Present", created[0].Status);

        var reloaded = (await _ctx.Attendance.GetByTimetableAsync(timetableId)).ToList();
        Assert.Equal(2, reloaded.Count);
        Assert.Contains(reloaded, a => a.StudentId == IntegrationScenarioSeed.Student01Id && a.Status == "Present");
        Assert.Contains(reloaded, a => a.StudentId == IntegrationScenarioSeed.Student02Id && a.Status == "Absent");
    }

    /// <summary>TC-T04 · Nhập điểm</summary>
    [Fact]
    public async Task TC_T04_SaveBulkGrades_PersistsScores()
    {
        var dto = new BulkGradeByTypeDto(
            IntegrationScenarioSeed.TeachingAssignmentMath10A1,
            IntegrationScenarioSeed.AssessmentType15MinId,
            new List<StudentScoreDto>
            {
                new(IntegrationScenarioSeed.Student01Id, 8.5m, "Tốt"),
                new(IntegrationScenarioSeed.Student02Id, 7.0m, null),
            });

        await _ctx.Grade.SaveBulkGradesByTypeAsync(dto, IntegrationScenarioSeed.Teacher01Id);

        var entries = (await _ctx.Grade.GetClassGradesByTypeAsync(
            IntegrationScenarioSeed.TeachingAssignmentMath10A1,
            IntegrationScenarioSeed.AssessmentType15MinId)).ToList();

        Assert.Equal(2, entries.Count);
        Assert.Contains(entries, e => e.StudentId == IntegrationScenarioSeed.Student01Id && e.Score == 8.5m);
    }

    // ── §5 HỌC SINH ─────────────────────────────────────────────────────────

    /// <summary>TC-S01 · Thời khóa biểu theo năm học (date-based enrollment)</summary>
    [Fact]
    public async Task TC_S01_StudentWeeklyTimetable_ResolvesClassByDate()
    {
        var result = await _ctx.Timetable.GetWeeklyByStudentAsync(
            IntegrationScenarioSeed.Student01Id,
            IntegrationScenarioSeed.TestDate);

        Assert.NotNull(result);
        Assert.Equal("10A1", result!.Enrollment!.ClassName);
        Assert.NotEmpty(result.Slots);
        Assert.Equal(IntegrationScenarioSeed.TestDate, result.ReferenceDate);
    }

    /// <summary>TC-S03 · Xem điểm danh (attendanceRate = có mặt + muộn)</summary>
    [Fact]
    public async Task TC_S03_AttendanceSummary_CountsPresentAndLate()
    {
        await _ctx.Attendance.BulkCreateAsync(new[]
        {
            new CreateAttendanceDto(1, IntegrationScenarioSeed.Student01Id, "Present", null, IntegrationScenarioSeed.Teacher01Id),
            new CreateAttendanceDto(1, IntegrationScenarioSeed.Student02Id, "Late", null, IntegrationScenarioSeed.Teacher01Id),
        });

        var summary = await _ctx.Attendance.GetStudentAttendanceSummaryAsync(
            IntegrationScenarioSeed.Student01Id,
            IntegrationScenarioSeed.SemesterHk1Id);

        Assert.Equal(1, summary.TotalPresent);
        Assert.Equal(0, summary.TotalAbsent);
    }

    // ── §6 PHỤ HUYNH ────────────────────────────────────────────────────────

    /// <summary>TC-P01 · Chọn con</summary>
    [Fact]
    public async Task TC_P01_ParentListsLinkedChildren()
    {
        var children = (await _ctx.ParentStudent.GetByParentAsync(IntegrationScenarioSeed.Parent01Id)).ToList();

        Assert.Single(children);
        Assert.Equal("student01", children[0].StudentCode);
    }

    /// <summary>TC-P02 · Xem TKB con</summary>
    [Fact]
    public async Task TC_P02_ParentChildTimetable_MatchesStudentView()
    {
        var studentTt = await _ctx.Timetable.GetWeeklyByStudentAsync(
            IntegrationScenarioSeed.Student01Id,
            IntegrationScenarioSeed.TestDate);
        Assert.NotNull(studentTt);

        var parentChildId = (await _ctx.ParentStudent.GetByParentAsync(IntegrationScenarioSeed.Parent01Id))
            .Single().StudentId;

        var parentViewTt = await _ctx.Timetable.GetWeeklyByStudentAsync(
            parentChildId,
            IntegrationScenarioSeed.TestDate);

        Assert.NotNull(parentViewTt);
        Assert.Equal(studentTt!.Slots.Count, parentViewTt!.Slots.Count);
        Assert.Equal(studentTt.Enrollment!.ClassId, parentViewTt.Enrollment!.ClassId);
    }

    // ── §7 E2E ──────────────────────────────────────────────────────────────

    /// <summary>E2E-2 + E2E-3 · GV điểm danh → HS thấy trên TKB</summary>
    [Fact]
    public async Task E2E_TeacherAttendance_VisibleInStudentTimetable()
    {
        await _ctx.Attendance.BulkCreateAsync(new[]
        {
            new CreateAttendanceDto(1, IntegrationScenarioSeed.Student01Id, "Present", null, IntegrationScenarioSeed.Teacher01Id),
        });

        var studentTt = await _ctx.Timetable.GetWeeklyByStudentAsync(
            IntegrationScenarioSeed.Student01Id,
            IntegrationScenarioSeed.TestDate);

        Assert.NotNull(studentTt);
        Assert.Contains(studentTt!.Attendance, a =>
            a.TimetableId == 1 && a.Status == "Present");
    }

    /// <summary>E2E-1 · Admin phân lớp HS</summary>
    [Fact]
    public async Task E2E_1_AdminEnrollsStudent_InSameYearBlocked()
    {
        var enrollment = await _ctx.StudentClass.GetEnrollmentAtDateAsync(
            IntegrationScenarioSeed.Student01Id,
            IntegrationScenarioSeed.TestDate);

        Assert.NotNull(enrollment.Enrollment);
        Assert.Equal(IntegrationScenarioSeed.Class10A1Id, enrollment.Enrollment!.ClassId);

        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _ctx.StudentClass.CreateAsync(new CreateStudentClassDto(
                IntegrationScenarioSeed.Student01Id,
                IntegrationScenarioSeed.Class10A2Id)));
    }

    /// <summary>E2E-4 · PH xem điểm danh con (cùng studentId)</summary>
    [Fact]
    public async Task E2E_4_ParentViewsChildAttendanceSummary()
    {
        await _ctx.Attendance.BulkCreateAsync(new[]
        {
            new CreateAttendanceDto(1, IntegrationScenarioSeed.Student01Id, "Present", null, IntegrationScenarioSeed.Teacher01Id),
        });

        var childId = (await _ctx.ParentStudent.GetByParentAsync(IntegrationScenarioSeed.Parent01Id))
            .Single().StudentId;

        var summary = await _ctx.Attendance.GetStudentAttendanceSummaryAsync(
            childId,
            IntegrationScenarioSeed.SemesterHk1Id);

        Assert.Equal(1, summary.TotalPresent);
    }

    /// <summary>E2E-6 · Admin khóa user</summary>
    [Fact]
    public async Task E2E_6_AdminLocksUser_LoginFails()
    {
        await _ctx.User.UpdateAsync(IntegrationScenarioSeed.Student01Id,
            new UpdateUserDto(null, null, null, null, null, null, false, null, null));

        var login = await _ctx.Auth.LoginAsync(new LoginRequestDto("0901000006", TestDataFactory.DefaultPassword));

        Assert.Equal(LoginFailureReason.AccountLocked, login.Failure);
    }
}
