using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IUserService
{
    Task<IEnumerable<UserDto>> GetAllAsync();
    Task<UserDto?> GetByIdAsync(int id);
    Task<IEnumerable<UserDto>> GetByRoleAsync(int roleId);
    Task<IEnumerable<UserDto>> GetByDepartmentAsync(int departmentId);
    Task<UserDto> CreateAsync(CreateUserDto dto);
    Task<UserDto?> UpdateAsync(int id, UpdateUserDto dto);
    Task<bool> DeleteAsync(int id);
}
