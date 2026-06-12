namespace PRM393API.DTOs;

public record StudentYearlySummaryDto(int YearlySummaryId, int StudentId, int AcademicYearId, decimal? YearlyGpa, string? YearlyConduct, int? RankId, int? EvaluatedBy, DateTime EvaluatedAt);
public record CreateYearlySummaryDto(int StudentId, int AcademicYearId, decimal? YearlyGpa, string? YearlyConduct, int? RankId, int? EvaluatedBy);
public record UpdateYearlySummaryDto(decimal? YearlyGpa, string? YearlyConduct, int? RankId);
