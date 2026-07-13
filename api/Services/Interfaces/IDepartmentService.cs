using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IDepartmentService
{
    Task<IEnumerable<DepartmentDto>> GetAllAsync();
    Task<DepartmentDto?> GetByIdAsync(int id);
    Task<DepartmentDto> CreateAsync(CreateDepartmentDto dto);
    Task<DepartmentDto?> UpdateAsync(int id, UpdateDepartmentDto dto);
    Task<bool> DeleteAsync(int id);
    Task<IEnumerable<UserDto>> GetTeachersAsync(int departmentId);
    Task<IEnumerable<TeachingAssignmentDto>> GetAssignmentsAsync(int departmentId);
}
