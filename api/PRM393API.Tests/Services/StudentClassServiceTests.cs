using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class StudentClassServiceTests
{
    private readonly Mock<IStudentClassRepository> _scRepo = new();
    private readonly Mock<IClassRepository> _classRepo = new();
    private readonly StudentClassService _sut;

    public StudentClassServiceTests()
    {
        _sut = new StudentClassService(_scRepo.Object, _classRepo.Object);
    }

    [Fact]
    public async Task CreateAsync_ClassNotFound_ThrowsKeyNotFound()
    {
        _classRepo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Class?)null);

        await Assert.ThrowsAsync<KeyNotFoundException>(() =>
            _sut.CreateAsync(new CreateStudentClassDto(10, 99)));
    }

    [Fact]
    public async Task CreateAsync_StudentAlreadyInSameYear_Throws()
    {
        var targetClass = TestDataFactory.CreateClass(id: 2, academicYearId: 1);
        var oldClass = TestDataFactory.CreateClass(id: 1, academicYearId: 1);
        _classRepo.Setup(r => r.GetByIdAsync(2)).ReturnsAsync(targetClass);
        _scRepo.Setup(r => r.GetByStudentAsync(10))
            .ReturnsAsync(new[] { TestDataFactory.CreateStudentClass(classId: 1) });
        _classRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(oldClass);

        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _sut.CreateAsync(new CreateStudentClassDto(10, 2)));

        Assert.Contains("đã được phân vào", ex.Message);
    }

    [Fact]
    public async Task CreateAsync_DifferentYear_AllowsEnrollment()
    {
        var targetClass = TestDataFactory.CreateClass(id: 3, academicYearId: 2);
        var oldClass = TestDataFactory.CreateClass(id: 1, academicYearId: 1);
        _classRepo.Setup(r => r.GetByIdAsync(3)).ReturnsAsync(targetClass);
        _scRepo.Setup(r => r.GetByStudentAsync(10))
            .ReturnsAsync(new[] { TestDataFactory.CreateStudentClass(classId: 1) });
        _classRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(oldClass);
        _scRepo.Setup(r => r.CreateAsync(It.IsAny<StudentClass>()))
            .ReturnsAsync((StudentClass sc) => { sc.StudentClassId = 5; return sc; });

        var result = await _sut.CreateAsync(new CreateStudentClassDto(10, 3));

        Assert.Equal(5, result.StudentClassId);
    }

    [Fact]
    public async Task CreateAsync_FirstEnrollment_Succeeds()
    {
        var targetClass = TestDataFactory.CreateClass(id: 1);
        _classRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(targetClass);
        _scRepo.Setup(r => r.GetByStudentAsync(10)).ReturnsAsync(Array.Empty<StudentClass>());
        _scRepo.Setup(r => r.CreateAsync(It.IsAny<StudentClass>()))
            .ReturnsAsync((StudentClass sc) => { sc.StudentClassId = 1; return sc; });

        var result = await _sut.CreateAsync(new CreateStudentClassDto(10, 1));

        Assert.Equal(10, result.StudentId);
        Assert.Equal(1, result.ClassId);
    }

    [Fact]
    public async Task GetByClassAsync_ReturnsMappedList()
    {
        _scRepo.Setup(r => r.GetByClassAsync(1))
            .ReturnsAsync(new[] { TestDataFactory.CreateStudentClass() });

        var list = (await _sut.GetByClassAsync(1)).ToList();

        Assert.Single(list);
        Assert.Equal("Nguyễn Test", list[0].StudentName);
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _scRepo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
