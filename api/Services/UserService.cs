using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class UserService(IUserRepository repo) : IUserService
{
    public async Task<IEnumerable<UserDto>> GetAllAsync()
    {
        var users = await repo.GetAllAsync();
        return users.Select(ToDto);
    }

    public async Task<UserDto?> GetByIdAsync(int id)
    {
        var user = await repo.GetByIdAsync(id);
        return user is null ? null : ToDto(user);
    }

    public async Task<IEnumerable<UserDto>> GetByRoleAsync(int roleId) =>
        (await repo.GetByRoleAsync(roleId)).Select(ToDto);

    public async Task<IEnumerable<UserDto>> GetByDepartmentAsync(int departmentId) =>
        (await repo.GetByDepartmentAsync(departmentId)).Select(ToDto);

    public async Task<UserDto> CreateAsync(CreateUserDto dto)
    {
        var email = NormalizeEmail(dto.Email);
        if (string.IsNullOrWhiteSpace(email))
            throw new ArgumentException("Email là bắt buộc.");

        var sameEmail = await repo.GetByEmailAsync(email);
        if (sameEmail is not null)
            throw new InvalidOperationException("Email đã tồn tại.");

        var user = new User
        {
            Username = dto.Username,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
            FullName = dto.FullName,
            RoleId = dto.RoleId,
            Email = email,
            PhoneNumber = dto.PhoneNumber,
            DepartmentId = dto.DepartmentId,
            DateOfBirth = dto.DateOfBirth,
            Gender = dto.Gender,
            Address = dto.Address,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
        };
        var created = await repo.CreateAsync(user);
        return ToDto(created);
    }

    public async Task<UserDto?> UpdateAsync(int id, UpdateUserDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.FullName = dto.FullName ?? existing.FullName;
        if (dto.Email is not null)
        {
            var email = NormalizeEmail(dto.Email);
            if (string.IsNullOrWhiteSpace(email))
                throw new ArgumentException("Email là bắt buộc.");

            var sameEmail = await repo.GetByEmailAsync(email);
            if (sameEmail is not null && sameEmail.UserId != id)
                throw new InvalidOperationException("Email đã tồn tại.");

            existing.Email = email;
        }
        existing.PhoneNumber = dto.PhoneNumber ?? existing.PhoneNumber;
        existing.Address = dto.Address ?? existing.Address;
        existing.Gender = dto.Gender ?? existing.Gender;
        existing.AvatarUrl = dto.AvatarUrl ?? existing.AvatarUrl;
        existing.IsActive = dto.IsActive ?? existing.IsActive;

        if (dto.RoleId.HasValue)
        {
            existing.RoleId = dto.RoleId.Value;
            existing.DepartmentId = dto.RoleId.Value is 2 or 3 ? dto.DepartmentId : null;
        }

        existing.UpdatedAt = DateTime.UtcNow;

        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) =>
        await repo.DeleteAsync(id);

    internal static UserDto ToDto(User u) => new(
        u.UserId, u.Username, u.FullName, u.Email, u.PhoneNumber,
        u.RoleId, u.Role?.RoleName ?? "", u.DepartmentId,
        u.DateOfBirth, u.Gender, u.Address, u.AvatarUrl,
        u.IsActive, u.CreatedAt);

    private static string NormalizeEmail(string? email) =>
        (email ?? string.Empty).Trim().ToLowerInvariant();
}
