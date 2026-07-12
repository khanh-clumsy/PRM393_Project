using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class AssignmentServiceTests
{
    private readonly Mock<IAssignmentRepository> _repo = new();
    private readonly AssignmentService _sut;

    public AssignmentServiceTests() => _sut = new AssignmentService(_repo.Object);

    private static Assignment Sample() => new()
    {
        AssignmentId = 1,
        TeachingAssignmentId = 1,
        Title = "Bài 1",
        DueDate = DateTime.UtcNow.AddDays(7),
        CreatedBy = 3,
        CreatedAt = DateTime.UtcNow,
        UpdatedAt = DateTime.UtcNow,
        IsDeleted = false,
    };

    [Fact]
    public async Task CreateAsync_SetsIsDeletedFalse()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<Assignment>())).ReturnsAsync((Assignment a) => a);
        var result = await _sut.CreateAsync(new CreateAssignmentDto(1, "Bài mới", null, null, DateTime.UtcNow.AddDays(3), 3));
        _repo.Verify(r => r.CreateAsync(It.Is<Assignment>(a => !a.IsDeleted)), Times.Once);
        Assert.Equal("Bài mới", result.Title);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Assignment?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateAssignmentDto("X", null, null, null)));
    }

    [Fact]
    public async Task DeleteAsync_CallsSoftDelete()
    {
        _repo.Setup(r => r.SoftDeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
        _repo.Verify(r => r.SoftDeleteAsync(1), Times.Once);
    }

    [Fact]
    public async Task GetByTeachingAssignmentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByTeachingAssignmentAsync(1)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByTeachingAssignmentAsync(1));
    }

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        Assert.Equal("Bài 1", (await _sut.GetByIdAsync(1))!.Title);
    }

    [Fact]
    public async Task GetAllAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetAllAsync());
    }
}
