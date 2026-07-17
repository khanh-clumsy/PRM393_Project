using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class AnnouncementServiceTests
{
    private readonly Mock<IAnnouncementRepository> _repo = new();
    private readonly Mock<IAnnouncementReadRepository> _readRepo = new();
    private readonly Mock<IStudentClassRepository> _studentClassRepo = new();
    private readonly Mock<IParentStudentRepository> _parentStudentRepo = new();
    private readonly Mock<ITeachingAssignmentRepository> _teachingAssignmentRepo = new();
    private readonly Mock<IClassRepository> _classRepo = new();
    private readonly AnnouncementService _sut;

    public AnnouncementServiceTests()
    {
        _readRepo.Setup(r => r.GetReadAnnouncementIdsAsync(It.IsAny<int>(), It.IsAny<IEnumerable<int>>()))
            .ReturnsAsync([]);
        _sut = new AnnouncementService(
            _repo.Object,
            _readRepo.Object,
            _studentClassRepo.Object,
            _parentStudentRepo.Object,
            _teachingAssignmentRepo.Object,
            _classRepo.Object);
    }

    private static Announcement Sample() => new()
    {
        AnnouncementId = 1,
        AuthorId = 1,
        Title = "Thông báo",
        Content = "Nội dung",
        AnnouncementType = "School",
        Priority = "Normal",
        IsDeleted = false,
        CreatedAt = DateTime.UtcNow,
        UpdatedAt = DateTime.UtcNow,
        AnnouncementTargets = new List<AnnouncementTarget> { new() { ClassId = 1 } },
    };

    [Fact]
    public async Task CreateAsync_SetsIsDeletedFalseAndPassesTargetClassIds()
    {
        var targetIds = new List<int?> { 1, 2 };
        _repo.Setup(r => r.CreateAsync(It.IsAny<Announcement>(), It.IsAny<List<int?>>()))
            .ReturnsAsync((Announcement a, List<int?> _) => a);
        var dto = new CreateAnnouncementDto(1, "Mới", "Chi tiết", "Class", "High", targetIds);
        var result = await _sut.CreateAsync(dto);
        _repo.Verify(r => r.CreateAsync(
            It.Is<Announcement>(a => !a.IsDeleted && a.AnnouncementType == "class" && a.Priority == "high"),
            It.Is<List<int?>>(ids => ids.SequenceEqual(targetIds))), Times.Once);
        Assert.Equal("Mới", result.Title);
    }

    [Fact]
    public async Task CreateAsync_GlobalWithoutTargets_AddsNullClassTarget()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<Announcement>(), It.IsAny<List<int?>>()))
            .ReturnsAsync((Announcement a, List<int?> ids) =>
            {
                a.AnnouncementTargets = ids.Select(id => new AnnouncementTarget { ClassId = id }).ToList();
                return a;
            });

        await _sut.CreateAsync(new CreateAnnouncementDto(1, "Toàn trường", "Nội dung", "global", "normal", []));

        _repo.Verify(r => r.CreateAsync(
            It.IsAny<Announcement>(),
            It.Is<List<int?>>(ids => ids.Count == 1 && ids[0] == null)), Times.Once);
    }

    [Fact]
    public async Task CreateForCurrentUserAsync_TeacherWithScopedClassAnnouncement_UsesJwtAuthor()
    {
        _teachingAssignmentRepo.Setup(r => r.GetByTeacherAsync(3))
            .ReturnsAsync([new TeachingAssignment { TeacherId = 3, ClassId = 101 }]);
        _classRepo.Setup(r => r.GetByHomeroomTeacherAsync(3))
            .ReturnsAsync(Array.Empty<Class>());
        _repo.Setup(r => r.CreateAsync(It.IsAny<Announcement>(), It.IsAny<List<int?>>()))
            .ReturnsAsync((Announcement a, List<int?> ids) =>
            {
                a.AnnouncementTargets = ids.Select(id => new AnnouncementTarget { ClassId = id }).ToList();
                return a;
            });

        await _sut.CreateForCurrentUserAsync(
            new CreateAnnouncementDto(999, "Lớp", "Nội dung", "class", "normal", [101]), 3, "Teacher");

        _repo.Verify(r => r.CreateAsync(
            It.Is<Announcement>(a => a.AuthorId == 3 && a.AnnouncementType == "class"),
            It.Is<List<int?>>(ids => ids.SequenceEqual(new int?[] { 101 }))), Times.Once);
    }

    [Fact]
    public async Task CreateForCurrentUserAsync_TeacherWithHomeroomClassAnnouncement_AllowsTarget()
    {
        _teachingAssignmentRepo.Setup(r => r.GetByTeacherAsync(3))
            .ReturnsAsync(Array.Empty<TeachingAssignment>());
        _classRepo.Setup(r => r.GetByHomeroomTeacherAsync(3))
            .ReturnsAsync([new Class { ClassId = 55, ClassName = "10A1", AcademicYearId = 1, HomeroomTeacherId = 3 }]);
        _repo.Setup(r => r.CreateAsync(It.IsAny<Announcement>(), It.IsAny<List<int?>>()))
            .ReturnsAsync((Announcement a, List<int?> ids) =>
            {
                a.AnnouncementTargets = ids.Select(id => new AnnouncementTarget { ClassId = id }).ToList();
                return a;
            });

        await _sut.CreateForCurrentUserAsync(
            new CreateAnnouncementDto(999, "Lớp", "Nội dung", "class", "normal", [55]), 3, "Teacher");

        _repo.Verify(r => r.CreateAsync(It.IsAny<Announcement>(), It.Is<List<int?>>(ids => ids.Contains(55))), Times.Once);
    }

    [Fact]
    public async Task CreateForCurrentUserAsync_TeacherWithGlobalAnnouncement_ThrowsUnauthorizedAccessException()
    {
        await Assert.ThrowsAsync<UnauthorizedAccessException>(() =>
            _sut.CreateForCurrentUserAsync(
                new CreateAnnouncementDto(3, "Toàn trường", "Nội dung", "global", "normal", []), 3, "Teacher"));
    }

    [Fact]
    public async Task CreateForCurrentUserAsync_TeacherWithUnscopedClass_ThrowsUnauthorizedAccessException()
    {
        _teachingAssignmentRepo.Setup(r => r.GetByTeacherAsync(3))
            .ReturnsAsync([new TeachingAssignment { TeacherId = 3, ClassId = 101 }]);
        _classRepo.Setup(r => r.GetByHomeroomTeacherAsync(3))
            .ReturnsAsync(Array.Empty<Class>());

        await Assert.ThrowsAsync<UnauthorizedAccessException>(() =>
            _sut.CreateForCurrentUserAsync(
                new CreateAnnouncementDto(3, "Lớp", "Nội dung", "class", "normal", [202]), 3, "Teacher"));
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Announcement?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateAnnouncementDto("X", null, null)));
    }

    [Fact]
    public async Task DeleteAsync_CallsSoftDelete()
    {
        _repo.Setup(r => r.SoftDeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }

    [Fact]
    public async Task GetByClassAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByClassAsync(1)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByClassAsync(1));
    }

    [Fact]
    public async Task GetByIdAsync_MapsTargetClassIds()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        var result = await _sut.GetByIdAsync(1);
        Assert.NotNull(result);
        Assert.Contains(1, result!.TargetClassIds);
    }

    [Fact]
    public async Task GetAllAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetAllAsync());
    }

    [Fact]
    public async Task GetMyFeedAsync_Student_ReturnsGlobalAndOwnClassOnly()
    {
        var global = Sample();
        global.AnnouncementId = 1;
        global.AnnouncementTargets = [new AnnouncementTarget { ClassId = null }];
        var ownClass = Sample();
        ownClass.AnnouncementId = 2;
        ownClass.AnnouncementTargets = [new AnnouncementTarget { ClassId = 101 }];

        _studentClassRepo.Setup(r => r.GetByStudentAsync(10))
            .ReturnsAsync([new StudentClass { StudentId = 10, ClassId = 101 }]);
        _repo.Setup(r => r.GetFeedByClassIdsAsync(It.Is<IEnumerable<int>>(ids => ids.SequenceEqual(new[] { 101 })), false))
            .ReturnsAsync([global, ownClass]);

        var result = (await _sut.GetMyFeedAsync(10, "Student")).ToList();

        Assert.Equal([1, 2], result.Select(a => a.AnnouncementId).ToArray());
    }
}
