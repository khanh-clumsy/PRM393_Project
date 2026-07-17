using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class AttendanceServiceTests
{
    private readonly Mock<IAttendanceRepository> _repo = new();
    private readonly Mock<ITimetableRepository> _timetableRepo = new();
    private readonly AttendanceService _sut;

    public AttendanceServiceTests() => _sut = new AttendanceService(_repo.Object, _timetableRepo.Object);

    private static AttendanceRecord Sample() => new()
    {
        AttendanceId = 1,
        TimetableId = 1,
        StudentId = 10,
        Status = "P",
        RecordedBy = 3,
        RecordedAt = DateTime.UtcNow,
    };

    [Fact]
    public async Task CreateAsync_SetsRecordedAt()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<AttendanceRecord>()))
            .ReturnsAsync((AttendanceRecord a) => a);
        var dto = new CreateAttendanceDto(1, 10, "Present", null, 3);
        var result = await _sut.CreateAsync(dto);
        Assert.Equal("Present", result.Status);
        _repo.Verify(r => r.CreateAsync(It.Is<AttendanceRecord>(a => a.Status == "P")), Times.Once);
        _repo.Verify(r => r.CreateAsync(It.Is<AttendanceRecord>(a => a.RecordedAt <= DateTime.UtcNow)), Times.Once);
    }

    [Fact]
    public async Task BulkCreateAsync_MapsAllRecords()
    {
        var dtos = new[]
        {
            new CreateAttendanceDto(1, 10, "Present", null, 3),
            new CreateAttendanceDto(1, 11, "Absent", "ốm", 3),
        };
        _repo.Setup(r => r.BulkCreateAsync(It.IsAny<IEnumerable<AttendanceRecord>>()))
            .ReturnsAsync((IEnumerable<AttendanceRecord> list) => list.ToList());
        var result = (await _sut.BulkCreateAsync(dtos)).ToList();
        Assert.Equal(2, result.Count);
        _repo.Verify(r => r.BulkCreateAsync(It.Is<IEnumerable<AttendanceRecord>>(records =>
            records.Any(a => a.StudentId == 10 && a.Status == "P") &&
            records.Any(a => a.StudentId == 11 && a.Status == "A"))), Times.Once);
    }

    [Fact]
    public async Task CreateForTeacherAsync_IgnoresBodyRecordedByAndUsesCurrentTeacher()
    {
        _timetableRepo.Setup(r => r.GetDetailAsync(1))
            .ReturnsAsync(new Timetable
            {
                TimetableId = 1,
                TeachingAssignment = new TeachingAssignment { TeacherId = 3 }
            });
        _repo.Setup(r => r.CreateAsync(It.IsAny<AttendanceRecord>()))
            .ReturnsAsync((AttendanceRecord a) => a);

        var result = await _sut.CreateForTeacherAsync(new CreateAttendanceDto(1, 10, "Present", null, 999), 3);

        Assert.Equal(3, result.RecordedBy);
        _repo.Verify(r => r.CreateAsync(It.Is<AttendanceRecord>(a => a.RecordedBy == 3)), Times.Once);
    }

    [Fact]
    public async Task CreateForTeacherAsync_TeacherWithoutTimetableAssignment_ThrowsUnauthorizedAccessException()
    {
        _timetableRepo.Setup(r => r.GetDetailAsync(1))
            .ReturnsAsync(new Timetable
            {
                TimetableId = 1,
                TeachingAssignment = new TeachingAssignment { TeacherId = 4 }
            });

        await Assert.ThrowsAsync<UnauthorizedAccessException>(() =>
            _sut.CreateForTeacherAsync(new CreateAttendanceDto(1, 10, "Present", null, 3), 3));
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((AttendanceRecord?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateAttendanceDto("Late", null)));
    }

    [Fact]
    public async Task BulkUpdateAsync_DelegatesToRepo()
    {
        var updates = new[] { new BulkUpdateAttendanceDto(1, "Late", "trễ 5p") };
        _repo.Setup(r => r.BulkUpdateAsync(It.IsAny<IEnumerable<(int id, string status, string? note)>>()))
            .ReturnsAsync(new[] { Sample() });
        var result = (await _sut.BulkUpdateAsync(updates)).ToList();
        Assert.Single(result);
        _repo.Verify(r => r.BulkUpdateAsync(It.Is<IEnumerable<(int id, string status, string? note)>>(updates =>
            updates.Any(u => u.id == 1 && u.status == "L"))), Times.Once);
    }

    [Fact]
    public async Task GetByStudentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByStudentAsync(10)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByStudentAsync(10));
    }

    [Fact]
    public async Task GetByTimetableAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByTimetableAsync(1)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByTimetableAsync(1));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
