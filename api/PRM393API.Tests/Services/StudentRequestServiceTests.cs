using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class StudentRequestServiceTests
{
    private readonly Mock<IStudentRequestRepository> _repo = new();
    private readonly Mock<IParentStudentRepository> _parentStudentRepo = new();
    private readonly Mock<ITeachingAssignmentRepository> _teachingAssignmentRepo = new();
    private readonly Mock<IClassRepository> _classRepo = new();
    private readonly StudentRequestService _sut;

    public StudentRequestServiceTests() => _sut = new StudentRequestService(
        _repo.Object,
        _parentStudentRepo.Object,
        _teachingAssignmentRepo.Object,
        _classRepo.Object);

    private static StudentRequest Sample() => new()
    {
        StudentRequestId = 1,
        StudentId = 10,
        RequestedBy = 10,
        LeaveDate = new DateOnly(2025, 11, 1),
        Reason = "ốm",
        Status = "Pending",
        CreatedAt = DateTime.UtcNow,
        Student = new User { UserId = 10, FullName = "Nguyễn Văn A", Username = "student01", PasswordHash = "x" },
        RequestedByNavigation = new User { UserId = 10, FullName = "Nguyễn Văn A", Username = "student01", PasswordHash = "x" },
    };

    [Fact]
    public async Task CreateAsync_DefaultStatusPending()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<StudentRequest>())).ReturnsAsync((StudentRequest r) => r);
        var dto = new CreateStudentRequestDto(10, 10, new DateOnly(2025, 11, 2), "việc gia đình", null);
        var result = await _sut.CreateAsync(dto);
        _repo.Verify(r => r.CreateAsync(It.Is<StudentRequest>(x => x.Status == "Pending")), Times.Once);
        Assert.Equal("việc gia đình", result.Reason);
    }

    [Fact]
    public async Task CreateForCurrentUserAsync_StudentForOtherStudent_ThrowsUnauthorizedAccessException()
    {
        var dto = new CreateStudentRequestDto(11, 10, new DateOnly(2025, 11, 2), "việc gia đình", null);

        await Assert.ThrowsAsync<UnauthorizedAccessException>(() => _sut.CreateForCurrentUserAsync(dto, 10, "Student"));
    }

    [Fact]
    public async Task CreateForCurrentUserAsync_ParentWithoutRelationship_ThrowsUnauthorizedAccessException()
    {
        _parentStudentRepo.Setup(r => r.GetByParentAsync(20)).ReturnsAsync(Array.Empty<ParentStudent>());
        var dto = new CreateStudentRequestDto(10, 20, new DateOnly(2025, 11, 2), "việc gia đình", null);

        await Assert.ThrowsAsync<UnauthorizedAccessException>(() => _sut.CreateForCurrentUserAsync(dto, 20, "Parent"));
    }

    [Fact]
    public async Task ReviewAsync_Approved_SetsReviewedAt()
    {
        var existing = Sample();
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.ReviewAsync(1, It.IsAny<StudentRequest>())).ReturnsAsync((int _, StudentRequest r) => r);
        var result = await _sut.ReviewAsync(1, new ReviewStudentRequestDto("Approved", 3, "OK"));
        Assert.Equal("Approved", result!.Status);
        Assert.NotNull(result.ReviewedAt);
    }

    [Fact]
    public async Task ReviewAsync_RejectedRequestAlreadyReviewed_ThrowsInvalidOperationException()
    {
        var existing = Sample();
        existing.Status = "Approved";
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);

        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _sut.ReviewAsync(1, new ReviewStudentRequestDto("Rejected", 3, "Không hợp lệ")));
    }

    [Fact]
    public async Task ReviewAsync_InvalidStatus_ThrowsArgumentException()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());

        await Assert.ThrowsAsync<ArgumentException>(() =>
            _sut.ReviewAsync(1, new ReviewStudentRequestDto("Pending", 3, null)));
    }

    [Fact]
    public async Task ReviewAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((StudentRequest?)null);
        Assert.Null(await _sut.ReviewAsync(99, new ReviewStudentRequestDto("Rejected", 3, "Không hợp lệ")));
    }

    [Fact]
    public async Task GetPendingAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetPendingAsync()).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetPendingAsync());
    }

    [Fact]
    public async Task GetByStudentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByStudentAsync(10)).ReturnsAsync(new[] { Sample() });
        var result = (await _sut.GetByStudentAsync(10)).Single();
        Assert.Equal("Nguyễn Văn A", result.StudentName);
        Assert.Equal("Nguyễn Văn A", result.RequestedByName);
    }

    [Fact]
    public async Task GetPendingForTeacherAsync_ReturnsOnlyStudentsInTeacherClasses()
    {
        _teachingAssignmentRepo.Setup(r => r.GetByTeacherAsync(3))
            .ReturnsAsync([new TeachingAssignment { TeacherId = 3, ClassId = 101 }]);
        _classRepo.Setup(r => r.GetByHomeroomTeacherAsync(3))
            .ReturnsAsync(Array.Empty<Class>());
        _repo.Setup(r => r.GetPendingByClassIdsAsync(It.Is<IEnumerable<int>>(ids => ids.Contains(101))))
            .ReturnsAsync([Sample()]);

        Assert.Single(await _sut.GetPendingForTeacherAsync(3));
    }

    [Fact]
    public async Task GetPendingForTeacherAsync_IncludesHomeroomClasses()
    {
        _teachingAssignmentRepo.Setup(r => r.GetByTeacherAsync(3))
            .ReturnsAsync(Array.Empty<TeachingAssignment>());
        _classRepo.Setup(r => r.GetByHomeroomTeacherAsync(3))
            .ReturnsAsync([new Class { ClassId = 55, ClassName = "10A1", AcademicYearId = 1, HomeroomTeacherId = 3 }]);
        _repo.Setup(r => r.GetPendingByClassIdsAsync(It.Is<IEnumerable<int>>(ids => ids.Contains(55))))
            .ReturnsAsync([Sample()]);

        Assert.Single(await _sut.GetPendingForTeacherAsync(3));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }

    [Fact]
    public async Task DeleteAsync_NonPending_ThrowsInvalidOperationException()
    {
        var existing = Sample();
        existing.Status = "Approved";
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);

        await Assert.ThrowsAsync<InvalidOperationException>(() => _sut.DeleteAsync(1));
    }
}