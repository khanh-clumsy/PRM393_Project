using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class TimetableSlotServiceTests
{
    private readonly Mock<ITimetableSlotRepository> _repo = new();
    private readonly TimetableSlotService _sut;

    public TimetableSlotServiceTests() => _sut = new TimetableSlotService(_repo.Object);

    private static TimetableSlot Sample() => new()
    {
        SlotId = 1,
        SlotName = "Tiết 1",
        StartTime = new TimeOnly(7, 0),
        EndTime = new TimeOnly(7, 45),
    };

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        Assert.Equal("Tiết 1", (await _sut.GetByIdAsync(1))!.SlotName);
    }

    [Fact]
    public async Task CreateAsync_MapsTimes()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<TimetableSlot>()))
            .ReturnsAsync((TimetableSlot s) => { s.SlotId = 2; return s; });
        var dto = new CreateTimetableSlotDto("Tiết 2", new TimeOnly(7, 50), new TimeOnly(8, 35));
        var result = await _sut.CreateAsync(dto);
        Assert.Equal(new TimeOnly(7, 50), result.StartTime);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((TimetableSlot?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateTimetableSlotDto("X", null, null)));
    }

    [Fact]
    public async Task GetAllAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetAllAsync());
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
