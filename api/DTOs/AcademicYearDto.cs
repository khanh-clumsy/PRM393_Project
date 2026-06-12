namespace PRM393API.DTOs;

public record AcademicYearDto(int AcademicYearId, string YearName, DateOnly StartDate, DateOnly EndDate, bool IsActive);

public record CreateAcademicYearDto(string YearName, DateOnly StartDate, DateOnly EndDate, bool IsActive = false);

public record UpdateAcademicYearDto(string? YearName, DateOnly? StartDate, DateOnly? EndDate, bool? IsActive);
