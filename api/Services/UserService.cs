using PRM393API.Common;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class UserService(IUserRepository repo, JwtHelper jwt) : IUserService
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

    public async Task<UserDto> CreateAsync(CreateUserDto dto)
    {
        var user = new User
        {
            Username = dto.Username,
            Email = dto.Email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
        };
        var created = await repo.CreateAsync(user);
        return ToDto(created);
    }

    public async Task<UserDto?> UpdateAsync(int id, UpdateUserDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.Username = dto.Username ?? existing.Username;
        existing.Email = dto.Email ?? existing.Email;

        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) =>
        await repo.DeleteAsync(id);

    public async Task<AuthResponseDto?> LoginAsync(LoginDto dto)
    {
        var user = await repo.GetByEmailAsync(dto.Email);
        if (user is null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
            return null;

        var token = jwt.GenerateToken(user);
        return new AuthResponseDto(token, ToDto(user));
    }

    private static UserDto ToDto(User u) => new(u.Id, u.Username, u.Email, u.CreatedAt);
}
