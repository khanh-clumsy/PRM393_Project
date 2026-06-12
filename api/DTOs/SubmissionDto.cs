namespace PRM393API.DTOs;

public record SubmissionDto(int SubmissionId, int AssignmentId, int StudentId, string? ContentText, string? FileUrl, string? LinkUrl, DateTime SubmittedAt, decimal? Score, string? Feedback, int? GradedBy, DateTime? GradedAt);
public record CreateSubmissionDto(int AssignmentId, int StudentId, string? ContentText, string? FileUrl, string? LinkUrl);
public record GradeSubmissionDto(decimal? Score, string? Feedback, int GradedBy);
