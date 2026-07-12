using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class ClassServiceTests
{
    private readonly Mock<IClassRepository> _repo = new();
    private readonly ClassService _sut;

    public ClassServiceTests() => _sut = new ClassService(_repo.Object);

    [Fact]
    public async Task CreateAsync_NoHomeroomTeacher_Succeeds()
    {
        var dto = new CreateClassDto("10A2", 1, null);
        _repo.Setup(r => r.CreateAsync(It.IsAny<Class>()))
            .ReturnsAsync((Class c) => { c.ClassId = 2; return c; });

        var result = await _sut.CreateAsync(dto);

        Assert.Equal("10A2", result.ClassName);
        _repo.Verify(r => r.GetByAcademicYearAsync(It.IsAny<int>()), Times.Never);
    }

    [Fact]
    public async Task CreateAsync_DuplicateHomeroomInSameYear_Throws()
    {
        var dto = new CreateClassDto("10A3", 1, 5);
        _repo.Setup(r => r.GetByAcademicYearAsync(1))
            .ReturnsAsync(new[] { TestDataFactory.CreateClass(homeroomTeacherId: 5) });

        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() => _sut.CreateAsync(dto));

        Assert.Contains("đã chủ nhiệm", ex.Message);
        _repo.Verify(r => r.CreateAsync(It.IsAny<Class>()), Times.Never);
    }

    [Fact]
    public async Task CreateAsync_UniqueHomeroom_Succeeds()
    {
        var dto = new CreateClassDto("10A4", 1, 6);
        _repo.Setup(r => r.GetByAcademicYearAsync(1))
            .ReturnsAsync(new[] { TestDataFactory.CreateClass(homeroomTeacherId: 5) });
        _repo.Setup(r => r.CreateAsync(It.IsAny<Class>()))
            .ReturnsAsync((Class c) => { c.ClassId = 4; return c; });

        var result = await _sut.CreateAsync(dto);

        Assert.Equal(6, result.HomeroomTeacherId);
    }

    [Fact]
    public async Task UpdateAsync_DuplicateHomeroom_Throws()
    {
        var existing = TestDataFactory.CreateClass(id: 1, homeroomTeacherId: 5);
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.GetByAcademicYearAsync(1))
            .ReturnsAsync(new[]
            {
                existing,
                TestDataFactory.CreateClass(id: 2, homeroomTeacherId: 7),
            });

        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _sut.UpdateAsync(1, new UpdateClassDto(null, 7)));
    }

    [Fact]
    public async Task UpdateAsync_SameHomeroom_NoConflict()
    {
        var existing = TestDataFactory.CreateClass(id: 1, homeroomTeacherId: 5);
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.UpdateAsync(1, It.IsAny<Class>()))
            .ReturnsAsync((int _, Class c) => c);

        var result = await _sut.UpdateAsync(1, new UpdateClassDto("10A1 đổi tên", 5));

        Assert.NotNull(result);
        Assert.Equal("10A1 đổi tên", result!.ClassName);
    }

    [Fact]
    public async Task GetByIdAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Class?)null);
        Assert.Null(await _sut.GetByIdAsync(99));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
