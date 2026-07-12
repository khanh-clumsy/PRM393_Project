using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class SubjectServiceTests
{
    private readonly Mock<ISubjectRepository> _repo = new();
    private readonly SubjectService _sut;

    public SubjectServiceTests() => _sut = new SubjectService(_repo.Object);

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(TestDataFactory.CreateSubject());
        var result = await _sut.GetByIdAsync(1);
        Assert.Equal("MATH", result!.SubjectCode);
    }

    [Fact]
    public async Task GetAllAsync_ReturnsActiveSubjects()
    {
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[] { TestDataFactory.CreateSubject() });
        Assert.Single(await _sut.GetAllAsync());
    }

    [Fact]
    public async Task CreateAsync_DefaultIsActiveTrue()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<Subject>()))
            .ReturnsAsync((Subject s) => { s.SubjectId = 2; return s; });
        var result = await _sut.CreateAsync(new CreateSubjectDto("PHY", "Vật lý"));
        Assert.True(result.IsActive);
    }

    [Fact]
    public async Task UpdateAsync_DeactivateSubject()
    {
        var existing = TestDataFactory.CreateSubject();
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.UpdateAsync(1, It.IsAny<Subject>()))
            .ReturnsAsync((int _, Subject s) => s);
        var result = await _sut.UpdateAsync(1, new UpdateSubjectDto(null, null, false));
        Assert.False(result!.IsActive);
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
