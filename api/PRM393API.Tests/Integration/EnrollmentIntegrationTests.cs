using PRM393API.DTOs;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Integration;

/// <summary>TC-A06 · Phân lớp · TC-A07 · PH–HS.</summary>
public class EnrollmentIntegrationTests : IDisposable
{
    private readonly IntegrationServiceProvider _ctx = new();

    public void Dispose() => _ctx.Dispose();

    [Fact]
    public async Task TC_A06_EnrollStudent_Succeeds()
    {
        var created = await _ctx.StudentClass.CreateAsync(new CreateStudentClassDto(
            IntegrationScenarioSeed.Student03Id,
            IntegrationScenarioSeed.Class10A1Id));

        Assert.Equal(IntegrationScenarioSeed.Student03Id, created.StudentId);
        Assert.Equal(IntegrationScenarioSeed.Class10A1Id, created.ClassId);

        var inClass = (await _ctx.StudentClass.GetByClassAsync(IntegrationScenarioSeed.Class10A1Id)).ToList();
        Assert.Contains(inClass, sc => sc.StudentId == IntegrationScenarioSeed.Student03Id);
    }

    [Fact]
    public async Task TC_A06_EnrollStudent_AlreadyInSameYear_Throws()
    {
        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _ctx.StudentClass.CreateAsync(new CreateStudentClassDto(
                IntegrationScenarioSeed.Student01Id,
                IntegrationScenarioSeed.Class10A2Id)));

        Assert.Contains("đã được phân", ex.Message);
    }

    [Fact]
    public async Task TC_A07_CreateParentStudentLink_Succeeds()
    {
        var link = await _ctx.ParentStudent.CreateAsync(new CreateParentStudentDto(
            IntegrationScenarioSeed.Parent01Id,
            IntegrationScenarioSeed.Student02Id,
            "Mẹ"));

        Assert.Equal("Mẹ", link.Relationship);
        Assert.Equal(IntegrationScenarioSeed.Student02Id, link.StudentId);
    }

    [Fact]
    public async Task TC_A07_DuplicateParentStudentLink_Throws()
    {
        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _ctx.ParentStudent.CreateAsync(new CreateParentStudentDto(
                IntegrationScenarioSeed.Parent01Id,
                IntegrationScenarioSeed.Student01Id,
                "Mẹ")));

        Assert.Contains("liên kết", ex.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task TC_A07_UpdateRelationship_Persists()
    {
        var updated = await _ctx.ParentStudent.UpdateAsync(1, new UpdateParentStudentDto("Bố"));

        Assert.NotNull(updated);
        Assert.Equal("Bố", updated!.Relationship);
    }

    [Fact]
    public async Task TC_A02_UnlockUser_CanLoginAgain()
    {
        await _ctx.User.UpdateAsync(IntegrationScenarioSeed.Student01Id,
            new UpdateUserDto(null, null, null, null, null, null, false, null, null));

        await _ctx.User.UpdateAsync(IntegrationScenarioSeed.Student01Id,
            new UpdateUserDto(null, null, null, null, null, null, true, null, null));

        var login = await _ctx.Auth.LoginAsync(new LoginRequestDto("0901000006", TestDataFactory.DefaultPassword));

        Assert.NotNull(login.Token);
        Assert.Equal(LoginFailureReason.None, login.Failure);
    }

    [Fact]
    public async Task TC_A03_UpdateUserDepartment_WhenRoleTeacher_Persists()
    {
        var updated = await _ctx.User.UpdateAsync(IntegrationScenarioSeed.Teacher01Id,
            new UpdateUserDto(null, null, null, null, null, null, null, 3, IntegrationScenarioSeed.DeptVanId));

        Assert.NotNull(updated);
        Assert.Equal(IntegrationScenarioSeed.DeptVanId, updated!.DepartmentId);
    }
}
