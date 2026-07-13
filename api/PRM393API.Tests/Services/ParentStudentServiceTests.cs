using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class ParentStudentServiceTests
{
    private readonly Mock<IParentStudentRepository> _repo = new();
    private readonly ParentStudentService _sut;

    public ParentStudentServiceTests() => _sut = new ParentStudentService(_repo.Object);

    private static ParentStudent Sample() => new()
    {
        ParentStudentId = 1,
        ParentId = 20,
        StudentId = 10,
        Relationship = "Bố",
        Parent = TestDataFactory.CreateUser(userId: 20, roleId: 5, roleName: "Parent"),
        Student = TestDataFactory.CreateUser(userId: 10, roleId: 4, roleName: "Student"),
    };

    [Fact]
    public async Task CreateAsync_MapsRelationship()
    {
        _repo.Setup(r => r.GetByStudentAsync(10)).ReturnsAsync(Array.Empty<ParentStudent>());
        _repo.Setup(r => r.GetByParentAsync(20)).ReturnsAsync(Array.Empty<ParentStudent>());
        _repo.Setup(r => r.CreateAsync(It.IsAny<ParentStudent>())).ReturnsAsync((ParentStudent ps) => ps);
        var result = await _sut.CreateAsync(new CreateParentStudentDto(20, 10, "Mẹ"));
        Assert.Equal("Mẹ", result.Relationship);
    }

    [Fact]
    public async Task CreateAsync_StudentAlreadyLinked_Throws()
    {
        _repo.Setup(r => r.GetByStudentAsync(10)).ReturnsAsync(new[] { Sample() });

        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _sut.CreateAsync(new CreateParentStudentDto(21, 10, "Mẹ")));

        Assert.Contains("đã được liên kết", ex.Message);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((ParentStudent?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateParentStudentDto("Bố")));
    }

    [Fact]
    public async Task GetByParentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByParentAsync(20)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByParentAsync(20));
    }

    [Fact]
    public async Task GetByStudentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByStudentAsync(10)).ReturnsAsync(new[] { Sample() });
        var list = (await _sut.GetByStudentAsync(10)).ToList();
        Assert.Single(list);
        Assert.Equal("Nguyễn Test", list[0].StudentName);
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
