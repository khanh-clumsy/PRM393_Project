namespace PRM393API.DTOs;

public record DepartmentDto(int DepartmentId, string DepartmentName, string? Description);

public record CreateDepartmentDto(string DepartmentName, string? Description);

public record UpdateDepartmentDto(string? DepartmentName, string? Description);
