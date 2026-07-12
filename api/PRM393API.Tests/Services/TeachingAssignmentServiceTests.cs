using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class TeachingAssignmentServiceTests
{
    private readonly Mock<ITeachingAssignmentRepository> _repo = new();
    private readonly TeachingAssignmentService _sut;

    public TeachingAssignmentServiceTests() => _sut = new TeachingAssignmentService(_repo.Object);

    [Fact]
    public async Task CreateAsync_DuplicateAssignment_Throws()
    {
        var dto = new CreateTeachingAssignmentDto(3, 1, 1, 1);
        _repo.Setup(r => r.GetByClassAsync(1))
            .ReturnsAsync(new[] { TestDataFactory.CreateTeachingAssignment(teacherId: 3, subjectId: 1, semesterId: 1) });

        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() => _sut.CreateAsync(dto));

        Assert.Contains("đã được phân công", ex.Message);
        _repo.Verify(r => r.CreateAsync(It.IsAny<TeachingAssignment>()), Times.Never);
    }

    [Fact]
    public async Task CreateAsync_UniqueAssignment_Succeeds()
    {
        var dto = new CreateTeachingAssignmentDto(3, 1, 2, 1);
        _repo.Setup(r => r.GetByClassAsync(1))
            .ReturnsAsync(new[] { TestDataFactory.CreateTeachingAssignment(subjectId: 1) });
        _repo.Setup(r => r.CreateAsync(It.IsAny<TeachingAssignment>()))
            .ReturnsAsync((TeachingAssignment ta) => { ta.TeachingAssignmentId = 10; return ta; });

        var result = await _sut.CreateAsync(dto);

        Assert.Equal(10, result.TeachingAssignmentId);
        Assert.Equal(2, result.SubjectId);
    }

    [Fact]
    public async Task UpdateAsync_ConflictWithOtherRecord_Throws()
    {
        var existing = TestDataFactory.CreateTeachingAssignment(id: 1, subjectId: 1);
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.GetByClassAsync(1))
            .ReturnsAsync(new[]
            {
                existing,
                TestDataFactory.CreateTeachingAssignment(id: 2, teacherId: 3, subjectId: 2, semesterId: 1),
            });

        var dto = new UpdateTeachingAssignmentDto(3, 1, 2, 1);

        await Assert.ThrowsAsync<InvalidOperationException>(() => _sut.UpdateAsync(1, dto));
    }

    [Fact]
    public async Task UpdateAsync_ValidChange_Succeeds()
    {
        var existing = TestDataFactory.CreateTeachingAssignment(id: 1);
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.GetByClassAsync(1)).ReturnsAsync(new[] { existing });
        _repo.Setup(r => r.UpdateAsync(It.IsAny<TeachingAssignment>()))
            .ReturnsAsync((TeachingAssignment ta) => ta);

        var result = await _sut.UpdateAsync(1, new UpdateTeachingAssignmentDto(4, 1, 1, 1));

        Assert.NotNull(result);
        Assert.Equal(4, result!.TeacherId);
    }

    [Fact]
    public async Task GetByIdAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((TeachingAssignment?)null);
        Assert.Null(await _sut.GetByIdAsync(99));
    }

    [Fact]
    public async Task GetByTeacherAsync_ReturnsMappedList()
    {
        _repo.Setup(r => r.GetByTeacherAsync(3))
            .ReturnsAsync(new[] { TestDataFactory.CreateTeachingAssignment() });

        var list = (await _sut.GetByTeacherAsync(3)).ToList();

        Assert.Single(list);
        Assert.Equal("10A1", list[0].ClassName);
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
