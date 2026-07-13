using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class DepartmentServiceTests
{
    private readonly Mock<IDepartmentRepository> _repo = new();
    private readonly Mock<IUserRepository> _userRepo = new();
    private readonly Mock<ITeachingAssignmentRepository> _taRepo = new();
    private readonly DepartmentService _sut;

    public DepartmentServiceTests()
    {
        _sut = new DepartmentService(_repo.Object, _userRepo.Object, _taRepo.Object);
    }

    private static Department SampleDept() => new()
    {
        DepartmentId = 1,
        DepartmentName = "Toán - Lý",
        Description = "Tổ Toán Lý",
    };

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(SampleDept());
        var result = await _sut.GetByIdAsync(1);
        Assert.Equal("Toán - Lý", result!.DepartmentName);
    }

    [Fact]
    public async Task CreateAsync_MapsFields()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<Department>()))
            .ReturnsAsync((Department d) => { d.DepartmentId = 2; return d; });
        var result = await _sut.CreateAsync(new CreateDepartmentDto("Hóa", "Tổ Hóa"));
        Assert.Equal("Hóa", result.DepartmentName);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Department?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateDepartmentDto("X", null)));
    }

    [Fact]
    public async Task GetAllAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[] { SampleDept() });
        Assert.Single(await _sut.GetAllAsync());
    }

    [Fact]
    public async Task GetTeachersAsync_ReturnsDepartmentTeachers()
    {
        _userRepo.Setup(r => r.GetByDepartmentAsync(1))
            .ReturnsAsync(new[] { TestDataFactory.CreateUser(userId: 3, roleId: 3, roleName: "Teacher") });
        var list = (await _sut.GetTeachersAsync(1)).ToList();
        Assert.Single(list);
        Assert.Equal(3, list[0].Id);
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
