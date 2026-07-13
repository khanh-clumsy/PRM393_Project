using PRM393API.Models;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class AcademicContextServiceTests : IDisposable
{
    private readonly Prm393dbContext _db;
    private readonly AcademicContextService _sut;

    public AcademicContextServiceTests()
    {
        _db = DbContextTestHelper.CreateInMemoryContext(Guid.NewGuid().ToString());
        _sut = new AcademicContextService(_db);
        Seed();
    }

    public void Dispose() => _db.Dispose();

    private void Seed()
    {
        var year2025 = TestDataFactory.CreateAcademicYear(id: 1);
        var year2026 = new AcademicYear
        {
            AcademicYearId = 2,
            YearName = "2026-2027",
            StartDate = new DateOnly(2026, 9, 1),
            EndDate = new DateOnly(2027, 5, 31),
            IsActive = false,
        };
        _db.AcademicYears.AddRange(year2025, year2026);
        _db.Semesters.AddRange(
            TestDataFactory.CreateSemester(id: 1, academicYearId: 1),
            new Semester
            {
                SemesterId = 2,
                AcademicYearId = 1,
                SemesterName = "Học kỳ 2",
                StartDate = new DateOnly(2026, 1, 16),
                EndDate = new DateOnly(2026, 5, 31),
            });
        _db.Classes.AddRange(
            TestDataFactory.CreateClass(id: 1, academicYearId: 1, className: "10A1"),
            TestDataFactory.CreateClass(id: 2, academicYearId: 2, className: "11A1"));
        var student = TestDataFactory.CreateUser(userId: 10, roleId: 4, roleName: "Student");
        _db.Users.Add(student);
        _db.StudentClasses.AddRange(
            new StudentClass { StudentClassId = 1, StudentId = 10, ClassId = 1 },
            new StudentClass { StudentClassId = 2, StudentId = 10, ClassId = 2 });
        _db.SaveChanges();
    }

    [Fact]
    public async Task ResolveAcademicYearAsync_UsesDateRange_NotIsActive()
    {
        var dateIn2026Year = new DateOnly(2026, 10, 1);
        var year = await _sut.ResolveAcademicYearAsync(dateIn2026Year);
        Assert.NotNull(year);
        Assert.Equal("2026-2027", year!.YearName);
    }

    [Fact]
    public async Task ResolveStudentEnrollmentAsync_PicksClassInResolvedYear()
    {
        var enrollment2025 = await _sut.ResolveStudentEnrollmentAsync(10, new DateOnly(2025, 10, 1));
        Assert.NotNull(enrollment2025);
        Assert.Equal(1, enrollment2025!.ClassId);
        Assert.Equal("10A1", enrollment2025.ClassName);

        var enrollment2026 = await _sut.ResolveStudentEnrollmentAsync(10, new DateOnly(2026, 10, 1));
        Assert.NotNull(enrollment2026);
        Assert.Equal(2, enrollment2026!.ClassId);
        Assert.Equal("11A1", enrollment2026.ClassName);
    }

    [Fact]
    public async Task GetContextAtDateAsync_ReturnsSemesterInsideYear()
    {
        var context = await _sut.GetContextAtDateAsync(new DateOnly(2025, 10, 1));
        Assert.NotNull(context.AcademicYear);
        Assert.Equal("2025-2026", context.AcademicYear!.Name);
        Assert.NotNull(context.Semester);
        Assert.Equal("Học kỳ 1", context.Semester!.Name);
    }
}
