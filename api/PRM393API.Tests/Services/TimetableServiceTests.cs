using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Services.Interfaces;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class TimetableServiceTests : IDisposable
{
    private readonly Mock<ITimetableRepository> _repo = new();
    private readonly Mock<IAcademicContextService> _academicContext = new();
    private readonly Prm393dbContext _db;
    private readonly TimetableService _sut;

    public TimetableServiceTests()
    {
        _db = DbContextTestHelper.CreateInMemoryContext(Guid.NewGuid().ToString());
        _sut = new TimetableService(_repo.Object, _db, _academicContext.Object);
    }

    public void Dispose() => _db.Dispose();

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        var tt = TestDataFactory.CreateTimetable();
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(tt);
        var result = await _sut.GetByIdAsync(1);
        Assert.Equal("P101", result!.RoomName);
    }

    [Fact]
    public async Task CreateAsync_MapsFields()
    {
        _db.TeachingAssignments.Add(new TeachingAssignment
        {
            TeacherId = 3,
            ClassId = 1,
            SubjectId = 1,
            SemesterId = 1,
        });
        await _db.SaveChangesAsync();
        var taId = _db.TeachingAssignments.Single().TeachingAssignmentId;

        var dto = new CreateTimetableDto(taId, new DateOnly(2025, 10, 7), 1, "P102", 1, null);
        _repo.Setup(r => r.CreateAsync(It.IsAny<Timetable>()))
            .ReturnsAsync((Timetable t) => { t.TimetableId = 5; return t; });
        var result = await _sut.CreateAsync(dto);
        Assert.Equal("P102", result.RoomName);
    }

    [Fact]
    public async Task CreateAsync_DuplicateAssignmentSlot_Throws()
    {
        var ta = new TeachingAssignment { TeacherId = 3, ClassId = 1, SubjectId = 1, SemesterId = 1 };
        _db.TeachingAssignments.Add(ta);
        await _db.SaveChangesAsync();

        _db.Timetables.Add(new Timetable
        {
            TeachingAssignmentId = ta.TeachingAssignmentId,
            Date = new DateOnly(2025, 10, 7),
            SlotId = 1,
            Status = 1,
        });
        await _db.SaveChangesAsync();

        var dto = new CreateTimetableDto(ta.TeachingAssignmentId, new DateOnly(2025, 10, 7), 1, "P102", 1, null);

        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() => _sut.CreateAsync(dto));
        Assert.Contains("trùng", ex.Message);
        _repo.Verify(r => r.CreateAsync(It.IsAny<Timetable>()), Times.Never);
    }

    [Fact]
    public async Task CreateTemplateAsync_DuplicateAssignmentSlot_Throws()
    {
        _db.Classes.Add(new Class { ClassId = 1, ClassName = "10A1", AcademicYearId = 1 });
        _db.Subjects.Add(new Subject { SubjectId = 1, SubjectCode = "M1", SubjectName = "Toán" });
        var ta = new TeachingAssignment { TeacherId = 3, ClassId = 1, SubjectId = 1, SemesterId = 1 };
        _db.TeachingAssignments.Add(ta);
        await _db.SaveChangesAsync();

        _db.TimetableTemplates.Add(new TimetableTemplate
        {
            TeachingAssignmentId = ta.TeachingAssignmentId,
            DayOfWeek = 2,
            SlotId = 1,
            RoomName = "P101",
        });
        await _db.SaveChangesAsync();

        var dto = new CreateTimetableTemplateDto(ta.TeachingAssignmentId, 2, 1, "P102");

        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() => _sut.CreateTemplateAsync(dto));
        Assert.Contains("trùng", ex.Message);
    }

    [Fact]
    public async Task CreateTemplateAsync_SameTeacherDifferentSemester_Allows()
    {
        _db.TimetableSlots.Add(new TimetableSlot { SlotId = 1, SlotName = "Tiết 1", StartTime = new TimeOnly(7, 0), EndTime = new TimeOnly(7, 45) });
        _db.Classes.AddRange(
            new Class { ClassId = 1, ClassName = "10A1", AcademicYearId = 1 },
            new Class { ClassId = 2, ClassName = "10A2", AcademicYearId = 1 });
        _db.Subjects.Add(new Subject { SubjectId = 1, SubjectCode = "M1", SubjectName = "Toán" });
        _db.Users.Add(new User { UserId = 3, Username = "gv1", FullName = "GV Test", RoleId = 2, PhoneNumber = "0900000003", PasswordHash = "x" });
        var ta1 = new TeachingAssignment { TeacherId = 3, ClassId = 1, SubjectId = 1, SemesterId = 1 };
        var ta2 = new TeachingAssignment { TeacherId = 3, ClassId = 2, SubjectId = 1, SemesterId = 2 };
        _db.TeachingAssignments.AddRange(ta1, ta2);
        await _db.SaveChangesAsync();

        _db.TimetableTemplates.Add(new TimetableTemplate
        {
            TeachingAssignmentId = ta1.TeachingAssignmentId,
            DayOfWeek = 2,
            SlotId = 1,
        });
        await _db.SaveChangesAsync();

        var dto = new CreateTimetableTemplateDto(ta2.TeachingAssignmentId, 2, 1, "P102");
        var result = await _sut.CreateTemplateAsync(dto);
        Assert.Equal(ta2.TeachingAssignmentId, result.TeachingAssignmentId);
    }

    [Fact]
    public async Task CreateTemplateAsync_SameTeacherDifferentSubjectSameSlot_Throws()
    {
        _db.Classes.Add(new Class { ClassId = 1, ClassName = "10A1", AcademicYearId = 1 });
        _db.Subjects.AddRange(
            new Subject { SubjectId = 1, SubjectCode = "M1", SubjectName = "Toán" },
            new Subject { SubjectId = 2, SubjectCode = "L1", SubjectName = "Lý" });
        var ta1 = new TeachingAssignment { TeacherId = 3, ClassId = 1, SubjectId = 1, SemesterId = 1 };
        var ta2 = new TeachingAssignment { TeacherId = 3, ClassId = 1, SubjectId = 2, SemesterId = 1 };
        _db.TeachingAssignments.AddRange(ta1, ta2);
        await _db.SaveChangesAsync();

        _db.TimetableTemplates.Add(new TimetableTemplate
        {
            TeachingAssignmentId = ta1.TeachingAssignmentId,
            DayOfWeek = 2,
            SlotId = 1,
        });
        await _db.SaveChangesAsync();

        var dto = new CreateTimetableTemplateDto(ta2.TeachingAssignmentId, 2, 1, null);

        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() => _sut.CreateTemplateAsync(dto));
        Assert.Contains("Giáo viên", ex.Message);
    }

    [Fact]
    public async Task GetWeeklyByClassAsync_CalculatesMondayWeek()
    {
        var monday = new DateOnly(2025, 10, 6);
        _repo.Setup(r => r.GetWeeklyByClassAsync(1, monday, monday.AddDays(6)))
            .ReturnsAsync(new List<Timetable>());
        var result = await _sut.GetWeeklyByClassAsync(1, new DateOnly(2025, 10, 8));
        Assert.Empty(result);
        _repo.Verify(r => r.GetWeeklyByClassAsync(1, monday, monday.AddDays(6)), Times.Once);
    }

    [Fact]
    public async Task GenerateTimetablesForSemesterAsync_SemesterNotFound_ReturnsZero()
    {
        var count = await _sut.GenerateTimetablesForSemesterAsync(999, new List<TimetableTemplateDto>());
        Assert.Equal(0, count);
    }

    [Fact]
    public async Task GenerateTimetablesForSemesterAsync_ValidSemester_CreatesEntries()
    {
        var sem = TestDataFactory.CreateSemester();
        _db.Semesters.Add(sem);
        var ta = TestDataFactory.CreateTeachingAssignment();
        _db.TeachingAssignments.Add(ta);
        await _db.SaveChangesAsync();

        var templates = new List<TimetableTemplateDto>
        {
            new(ta.TeachingAssignmentId, (byte)2, 1, "P101"),
        };

        _repo.Setup(r => r.BulkCreateAsync(It.IsAny<IEnumerable<Timetable>>()))
            .ReturnsAsync((IEnumerable<Timetable> list) => list);

        var count = await _sut.GenerateTimetablesForSemesterAsync(sem.SemesterId, templates);

        Assert.True(count > 0);
        _repo.Verify(r => r.BulkCreateAsync(It.IsAny<IEnumerable<Timetable>>()), Times.Once);
    }

    [Fact]
    public async Task ClearGeneratedTimetablesAsync_NoAssignments_ReturnsZero()
    {
        var count = await _sut.ClearGeneratedTimetablesAsync(999, 1);
        Assert.Equal(0, count);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Timetable?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateTimetableDto(null, null, null, null, null)));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }

    [Fact]
    public async Task GetByClassAsync_ReturnsMappedList()
    {
        _repo.Setup(r => r.GetByClassAsync(1)).ReturnsAsync(new[] { TestDataFactory.CreateTimetable() });
        Assert.Single(await _sut.GetByClassAsync(1));
    }

    [Fact]
    public async Task GetDetailAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetDetailAsync(99)).ReturnsAsync((Timetable?)null);
        Assert.Null(await _sut.GetDetailAsync(99));
    }
}
