namespace PRM393API.DTOs;

public record GradeDto(int GradeId, int AssessmentId, int StudentId, decimal? Score, string? Comment, int EnteredBy, DateTime EnteredAt);
public record CreateGradeDto(int AssessmentId, int StudentId, decimal? Score, string? Comment, int EnteredBy);
public record UpdateGradeDto(decimal? Score, string? Comment);
