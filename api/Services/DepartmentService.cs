using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class DepartmentService(
    IDepartmentRepository repo,
    IUserRepository userRepo,
    ITeachingAssignmentRepository taRepo) : IDepartmentService
{
    public async Task<IEnumerable<DepartmentDto>> GetAllAsync()
    {
        var list = await repo.GetAllAsync();
        return list.Select(ToDto);
    }

    public async Task<DepartmentDto?> GetByIdAsync(int id)
    {
        var dept = await repo.GetByIdAsync(id);
        return dept is null ? null : ToDto(dept);
    }

    public async Task<DepartmentDto> CreateAsync(CreateDepartmentDto dto)
    {
        var dept = new Department
        {
            DepartmentName = dto.DepartmentName,
            Description = dto.Description,
        };
        var created = await repo.CreateAsync(dept);
        return ToDto(created);
    }

    public async Task<DepartmentDto?> UpdateAsync(int id, UpdateDepartmentDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.DepartmentName = dto.DepartmentName ?? existing.DepartmentName;
        existing.Description = dto.Description ?? existing.Description;

        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) =>
        await repo.DeleteAsync(id);

    public async Task<IEnumerable<UserDto>> GetTeachersAsync(int departmentId) =>
        (await userRepo.GetByDepartmentAsync(departmentId)).Select(ToUserDto);

    public async Task<IEnumerable<TeachingAssignmentDto>> GetAssignmentsAsync(int departmentId)
    {
        var list = await taRepo.GetByDepartmentAsync(departmentId);
        return list.Select(ta => new TeachingAssignmentDto(
            ta.TeachingAssignmentId, ta.TeacherId, ta.ClassId, ta.SubjectId, ta.SemesterId,
            ta.Class?.ClassName, ta.Subject?.SubjectName));
    }

    private static DepartmentDto ToDto(Department d) =>
        new(d.DepartmentId, d.DepartmentName, d.Description);

    private static UserDto ToUserDto(User u) => new(
        u.UserId, u.Username, u.FullName, u.Email, u.PhoneNumber,
        u.RoleId, u.Role?.RoleName ?? "", u.DepartmentId,
        u.DateOfBirth, u.Gender, u.Address, u.AvatarUrl,
        u.IsActive, u.CreatedAt);
}
