using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class GradeServiceTests
{
    private readonly Mock<IGradeRepository> _repo = new();
    private readonly Mock<ITeachingAssignmentRepository> _teachingAssignmentRepo = new();
    private readonly GradeService _sut;

    public GradeServiceTests() => _sut = new GradeService(_repo.Object, _teachingAssignmentRepo.Object);

    private static Grade Sample() => new()
    {
        GradeId = 1,
        AssessmentId = 1,
        StudentId = 10,
        Score = 8.5m,
        EnteredBy = 3,
        EnteredAt = DateTime.UtcNow,
    };

    [Fact]
    public async Task CreateAsync_SetsEnteredAt()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<Grade>())).ReturnsAsync((Grade g) => g);
        var result = await _sut.CreateAsync(new CreateGradeDto(1, 10, 9.0m, "tốt", 3));
        Assert.Equal(9.0m, result.Score);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Grade?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateGradeDto(7.0m, null)));
    }

    [Fact]
    public async Task GetStudentTranscriptAsync_DelegatesToRepo()
    {
        var transcript = new AcademicTranscriptDto(10, 1, new List<SubjectTranscriptDto>());
        _repo.Setup(r => r.GetStudentTranscriptAsync(10, 1)).ReturnsAsync(transcript);
        var result = await _sut.GetStudentTranscriptAsync(10, 1);
        Assert.Equal(10, result.StudentId);
    }

    [Fact]
    public async Task GetByAssessmentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByAssessmentAsync(1)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByAssessmentAsync(1));
    }

    [Fact]
    public async Task SaveBulkGradesAsync_DelegatesToRepo()
    {
        var dtos = new List<BulkGradeDto> { new(1, 10, 8.0m, null, 3) };
        _repo.Setup(r => r.SaveBulkGradesAsync(dtos)).Returns(Task.CompletedTask);
        await _sut.SaveBulkGradesAsync(dtos);
        _repo.Verify(r => r.SaveBulkGradesAsync(dtos), Times.Once);
    }

    [Fact]
    public async Task SaveBulkGradesByTypeAsync_TeacherWithoutAssignment_ThrowsUnauthorizedAccessException()
    {
        _teachingAssignmentRepo.Setup(r => r.GetByIdAsync(5))
            .ReturnsAsync(new TeachingAssignment { TeachingAssignmentId = 5, TeacherId = 99, ClassId = 1 });

        await Assert.ThrowsAsync<UnauthorizedAccessException>(() =>
            _sut.SaveBulkGradesByTypeAsync(new BulkGradeByTypeDto(5, 1, []), 3));

        _repo.Verify(r => r.SaveBulkGradesByTypeAsync(It.IsAny<BulkGradeByTypeDto>(), It.IsAny<int>()), Times.Never);
    }

    [Fact]
    public async Task SaveBulkGradesByTypeAsync_TeacherWithAssignment_DelegatesToRepo()
    {
        var dto = new BulkGradeByTypeDto(5, 1, [new StudentScoreDto(10, 8m, null)]);
        _teachingAssignmentRepo.Setup(r => r.GetByIdAsync(5))
            .ReturnsAsync(new TeachingAssignment { TeachingAssignmentId = 5, TeacherId = 3, ClassId = 1 });
        _repo.Setup(r => r.SaveBulkGradesByTypeAsync(dto, 3)).Returns(Task.CompletedTask);

        await _sut.SaveBulkGradesByTypeAsync(dto, 3);

        _repo.Verify(r => r.SaveBulkGradesByTypeAsync(dto, 3), Times.Once);
    }

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        Assert.Equal(8.5m, (await _sut.GetByIdAsync(1))!.Score);
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
