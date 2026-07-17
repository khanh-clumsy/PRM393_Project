using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class ClassSummaryServiceTests
{
    private readonly Mock<IClassRepository> _classRepo = new();
    private readonly Mock<IStudentClassRepository> _studentClassRepo = new();
    private readonly Mock<IStudentSemesterSummaryRepository> _semesterSummaryRepo = new();
    private readonly Mock<IStudentYearlySummaryRepository> _yearlySummaryRepo = new();
    private readonly Mock<IAcademicRankRepository> _rankRepo = new();
    private readonly Mock<IUserRepository> _userRepo = new();
    private readonly ClassSummaryService _sut;

    public ClassSummaryServiceTests() =>
        _sut = new ClassSummaryService(
            _classRepo.Object,
            _studentClassRepo.Object,
            _semesterSummaryRepo.Object,
            _yearlySummaryRepo.Object,
            _rankRepo.Object,
            _userRepo.Object);

    [Fact]
    public async Task GetSemesterBoardAsync_NotHomeroom_Throws()
    {
        _classRepo.Setup(r => r.GetByIdAsync(1))
            .ReturnsAsync(TestDataFactory.CreateClass(id: 1, homeroomTeacherId: 99));

        await Assert.ThrowsAsync<UnauthorizedAccessException>(() =>
            _sut.GetSemesterBoardAsync(1, 10, teacherId: 3));
    }

    [Fact]
    public async Task GetSemesterBoardAsync_Homeroom_ReturnsRows()
    {
        _classRepo.Setup(r => r.GetByIdAsync(1))
            .ReturnsAsync(TestDataFactory.CreateClass(id: 1, homeroomTeacherId: 3));
        _studentClassRepo.Setup(r => r.GetByClassAsync(1)).ReturnsAsync(new[]
        {
            new StudentClass { StudentId = 6, ClassId = 1 },
        });
        _userRepo.Setup(r => r.GetByIdAsync(6)).ReturnsAsync(new User
        {
            UserId = 6,
            Username = "student01",
            PasswordHash = "x",
            FullName = "Nguyen Van A",
        });
        _semesterSummaryRepo.Setup(r => r.GetByStudentAsync(6)).ReturnsAsync(new[]
        {
            new StudentSemesterSummary
            {
                SummaryId = 1,
                StudentId = 6,
                SemesterId = 10,
                Gpa = 8.5m,
                Conduct = "Tốt",
                RankId = 1,
            },
        });
        _rankRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(new AcademicRank
        {
            RankId = 1,
            RankName = "Giỏi",
            MinScore = 8,
            MaxScore = 10,
        });

        var rows = await _sut.GetSemesterBoardAsync(1, 10, 3);

        Assert.Single(rows);
        Assert.Equal(6, rows[0].StudentId);
        Assert.True(rows[0].IsFinalized);
        Assert.Equal("Tốt", rows[0].Conduct);
        Assert.Equal("Giỏi", rows[0].RankName);
    }

    [Fact]
    public async Task UpsertSemesterAsync_InvalidConduct_Throws()
    {
        _classRepo.Setup(r => r.GetByIdAsync(1))
            .ReturnsAsync(TestDataFactory.CreateClass(id: 1, homeroomTeacherId: 3));
        _studentClassRepo.Setup(r => r.GetByClassAsync(1)).ReturnsAsync(new[]
        {
            new StudentClass { StudentId = 6, ClassId = 1 },
        });

        await Assert.ThrowsAsync<ArgumentException>(() =>
            _sut.UpsertSemesterAsync(1, 6, 10, 3, new UpsertSemesterSummaryDto("Siêu tốt", null, 8m)));
    }

    [Fact]
    public async Task UpsertSemesterAsync_MapsRankFromGpa_AndCreates()
    {
        _classRepo.Setup(r => r.GetByIdAsync(1))
            .ReturnsAsync(TestDataFactory.CreateClass(id: 1, homeroomTeacherId: 3));
        _studentClassRepo.Setup(r => r.GetByClassAsync(1)).ReturnsAsync(new[]
        {
            new StudentClass { StudentId = 6, ClassId = 1 },
        });
        _semesterSummaryRepo.Setup(r => r.GetByStudentAsync(6))
            .ReturnsAsync(Array.Empty<StudentSemesterSummary>());
        _rankRepo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[]
        {
            new AcademicRank { RankId = 1, RankName = "Giỏi", MinScore = 8.0m, MaxScore = 10m },
        });
        _semesterSummaryRepo.Setup(r => r.CreateAsync(It.IsAny<StudentSemesterSummary>()))
            .ReturnsAsync((StudentSemesterSummary s) =>
            {
                s.SummaryId = 99;
                return s;
            });

        var result = await _sut.UpsertSemesterAsync(1, 6, 10, 3,
            new UpsertSemesterSummaryDto("Tốt", null, 8.5m));

        Assert.Equal(99, result.SummaryId);
        Assert.Equal(1, result.RankId);
        Assert.Equal("Tốt", result.Conduct);
        Assert.Equal(8.5m, result.Gpa);
    }
}
