namespace PRM393API.DTOs;

public record SemesterDto(int SemesterId, int AcademicYearId, string SemesterName, DateOnly StartDate, DateOnly EndDate);

public record CreateSemesterDto(int AcademicYearId, string SemesterName, DateOnly StartDate, DateOnly EndDate);

public record UpdateSemesterDto(string? SemesterName, DateOnly? StartDate, DateOnly? EndDate);
