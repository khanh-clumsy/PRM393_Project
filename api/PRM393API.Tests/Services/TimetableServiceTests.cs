using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class TimetableServiceTests : IDisposable
{
    private readonly Mock<ITimetableRepository> _repo = new();
    private readonly Prm393dbContext _db;
    private readonly TimetableService _sut;

    public TimetableServiceTests()
    {
        _db = DbContextTestHelper.CreateInMemoryContext(Guid.NewGuid().ToString());
        _sut = new TimetableService(_repo.Object, _db);
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
        var dto = new CreateTimetableDto(1, new DateOnly(2025, 10, 7), 1, "P102", 1, null);
        _repo.Setup(r => r.CreateAsync(It.IsAny<Timetable>()))
            .ReturnsAsync((Timetable t) => { t.TimetableId = 5; return t; });
        var result = await _sut.CreateAsync(dto);
        Assert.Equal("P102", result.RoomName);
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
