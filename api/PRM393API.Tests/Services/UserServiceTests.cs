using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class UserServiceTests
{
    private readonly Mock<IUserRepository> _repo = new();
    private readonly UserService _sut;

    public UserServiceTests()
    {
        _sut = new UserService(_repo.Object);
    }

    [Fact]
    public async Task CreateAsync_SetsIsActiveTrue()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<User>()))
            .ReturnsAsync((User u) => u);

        var dto = new CreateUserDto(
            "student99",
            TestDataFactory.DefaultPassword,
            "Học sinh mới",
            4,
            "student99@fschool.edu.vn",
            "0901111222",
            null,
            null,
            null,
            null);

        var result = await _sut.CreateAsync(dto);

        Assert.True(result.IsActive);
        _repo.Verify(r => r.CreateAsync(It.Is<User>(u => u.IsActive)), Times.Once);
    }

    [Fact]
    public async Task UpdateAsync_SetIsActiveFalse_PersistsInactive()
    {
        var existing = TestDataFactory.CreateUser(isActive: true);
        _repo.Setup(r => r.GetByIdAsync(existing.UserId)).ReturnsAsync(existing);
        _repo.Setup(r => r.UpdateAsync(existing.UserId, It.IsAny<User>()))
            .ReturnsAsync((int _, User u) => u);

        var result = await _sut.UpdateAsync(existing.UserId, new UpdateUserDto(
            FullName: null,
            Email: null,
            PhoneNumber: null,
            Address: null,
            Gender: null,
            AvatarUrl: null,
            IsActive: false));

        Assert.NotNull(result);
        Assert.False(result!.IsActive);
    }

    [Fact]
    public async Task UpdateAsync_IsActiveNull_KeepsExistingValue()
    {
        var existing = TestDataFactory.CreateUser(isActive: false);
        _repo.Setup(r => r.GetByIdAsync(existing.UserId)).ReturnsAsync(existing);
        _repo.Setup(r => r.UpdateAsync(existing.UserId, It.IsAny<User>()))
            .ReturnsAsync((int _, User u) => u);

        var result = await _sut.UpdateAsync(existing.UserId, new UpdateUserDto(
            FullName: "Tên mới",
            Email: null,
            PhoneNumber: null,
            Address: null,
            Gender: null,
            AvatarUrl: null,
            IsActive: null));

        Assert.NotNull(result);
        Assert.False(result!.IsActive);
        Assert.Equal("Tên mới", result.FullName);
    }

    [Fact]
    public async Task UpdateAsync_UserNotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((User?)null);

        var result = await _sut.UpdateAsync(999, new UpdateUserDto(
            FullName: "X",
            Email: null,
            PhoneNumber: null,
            Address: null,
            Gender: null,
            AvatarUrl: null,
            IsActive: false));

        Assert.Null(result);
        _repo.Verify(r => r.UpdateAsync(It.IsAny<int>(), It.IsAny<User>()), Times.Never);
    }

    [Fact]
    public async Task GetByIdAsync_ExistingUser_ReturnsDto()
    {
        var user = TestDataFactory.CreateUser();
        _repo.Setup(r => r.GetByIdAsync(user.UserId)).ReturnsAsync(user);

        var result = await _sut.GetByIdAsync(user.UserId);

        Assert.NotNull(result);
        Assert.Equal(user.UserId, result!.Id);
        Assert.Equal(user.FullName, result.FullName);
    }

    [Fact]
    public async Task GetByIdAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((User?)null);
        var result = await _sut.GetByIdAsync(999);
        Assert.Null(result);
    }

    [Fact]
    public async Task GetAllAsync_ReturnsMappedDtos()
    {
        var users = new[] { TestDataFactory.CreateUser(userId: 1), TestDataFactory.CreateUser(userId: 2, phone: "0901000007") };
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(users);

        var result = (await _sut.GetAllAsync()).ToList();

        Assert.Equal(2, result.Count);
        Assert.All(result, dto => Assert.False(string.IsNullOrWhiteSpace(dto.FullName)));
    }

    [Fact]
    public async Task DeleteAsync_ExistingUser_ReturnsTrue()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        var result = await _sut.DeleteAsync(1);
        Assert.True(result);
    }
}
