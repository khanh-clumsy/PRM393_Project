using PRM393API.DTOs;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Integration;

/// <summary>TC-A04 · Phân công giảng dạy.</summary>
public class TeachingAssignmentIntegrationTests : IDisposable
{
    private readonly IntegrationServiceProvider _ctx = new();

    public void Dispose() => _ctx.Dispose();

    [Fact]
    public async Task TC_A04_CreateTeachingAssignment_Succeeds()
    {
        var created = await _ctx.TeachingAssignment.CreateAsync(new CreateTeachingAssignmentDto(
            IntegrationScenarioSeed.Teacher01Id,
            IntegrationScenarioSeed.Class10A2Id,
            1,
            IntegrationScenarioSeed.SemesterHk1Id));

        Assert.Equal(IntegrationScenarioSeed.Class10A2Id, created.ClassId);
        Assert.Equal("Toán", created.SubjectName);
    }

    [Fact]
    public async Task TC_A04_DuplicateAssignment_Throws()
    {
        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _ctx.TeachingAssignment.CreateAsync(new CreateTeachingAssignmentDto(
                IntegrationScenarioSeed.Teacher01Id,
                IntegrationScenarioSeed.Class10A1Id,
                1,
                IntegrationScenarioSeed.SemesterHk1Id)));

        Assert.Contains("đã được phân công", ex.Message);
    }

    [Fact]
    public async Task TC_A04_UpdateTeachingAssignment_ChangesTeacher()
    {
        var updated = await _ctx.TeachingAssignment.UpdateAsync(
            IntegrationScenarioSeed.TeachingAssignmentMath10A1,
            new UpdateTeachingAssignmentDto(
                IntegrationScenarioSeed.Teacher02Id,
                IntegrationScenarioSeed.Class10A1Id,
                1,
                IntegrationScenarioSeed.SemesterHk1Id));

        Assert.NotNull(updated);
        Assert.Equal(IntegrationScenarioSeed.Teacher02Id, updated!.TeacherId);
    }

    [Fact]
    public async Task TC_A04_GetByTeacher_ReturnsAssignments()
    {
        var list = (await _ctx.TeachingAssignment.GetByTeacherAsync(IntegrationScenarioSeed.Teacher01Id)).ToList();

        Assert.NotEmpty(list);
        Assert.Contains(list, a => a.ClassName == "10A1" && a.SubjectName == "Toán");
    }
}
