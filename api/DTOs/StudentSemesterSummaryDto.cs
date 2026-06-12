namespace PRM393API.DTOs;

public record StudentSemesterSummaryDto(int SummaryId, int StudentId, int SemesterId, decimal? Gpa, string? Conduct, int? RankId, int? EvaluatedBy, DateTime EvaluatedAt);
public record CreateSemesterSummaryDto(int StudentId, int SemesterId, decimal? Gpa, string? Conduct, int? RankId, int? EvaluatedBy);
public record UpdateSemesterSummaryDto(decimal? Gpa, string? Conduct, int? RankId);
