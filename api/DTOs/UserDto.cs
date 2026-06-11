namespace PRM393API.DTOs;

public record UserDto(int Id, string Username, string Email, DateTime CreatedAt);

public record CreateUserDto(string Username, string Email, string Password);

public record UpdateUserDto(string? Username, string? Email);

public record LoginDto(string Email, string Password);

public record AuthResponseDto(string Token, UserDto User);
