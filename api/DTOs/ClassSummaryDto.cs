namespace PRM393API.DTOs;

public record ClassSemesterSummaryRowDto(
    int StudentId,
    string StudentName,
    string? StudentCode,
    int? SummaryId,
    decimal? Gpa,
    string? Conduct,
    int? RankId,
    string? RankName,
    bool IsFinalized);

public record ClassYearlySummaryRowDto(
    int StudentId,
    string StudentName,
    string? StudentCode,
    int? YearlySummaryId,
    decimal? YearlyGpa,
    string? YearlyConduct,
    int? RankId,
    string? RankName,
    bool IsFinalized);

/// <summary>GVCN chốt học kỳ. RankId optional — server map từ GPA nếu null.</summary>
public record UpsertSemesterSummaryDto(string Conduct, int? RankId, decimal? Gpa);

/// <summary>GVCN chốt cả năm.</summary>
public record UpsertYearlySummaryDto(string YearlyConduct, int? RankId, decimal? YearlyGpa);
