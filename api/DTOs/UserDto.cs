namespace PRM393API.DTOs;

public record UserDto(
    int Id,
    string Username,
    string FullName,
    string? Email,
    string? PhoneNumber,
    int RoleId,
    int? DepartmentId,
    bool IsActive,
    DateTime CreatedAt);

public record CreateUserDto(
    string Username,
    string Password,
    string FullName,
    int RoleId,
    string? Email,
    string? PhoneNumber,
    int? DepartmentId,
    DateOnly? DateOfBirth,
    string? Gender,
    string? Address);

public record UpdateUserDto(
    string? FullName,
    string? Email,
    string? PhoneNumber,
    string? Address,
    string? Gender,
    string? AvatarUrl,
    bool? IsActive);
