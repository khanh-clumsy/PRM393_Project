namespace PRM393API.DTOs;

public record ClassDto(int ClassId, string ClassName, int AcademicYearId, int? HomeroomTeacherId);

public record CreateClassDto(string ClassName, int AcademicYearId, int? HomeroomTeacherId);

public record UpdateClassDto(string? ClassName, int? HomeroomTeacherId);
