namespace PRM393API.DTOs;

public record AssessmentDto(int AssessmentId, int TeachingAssignmentId, int AssessmentTypeId, string AssessmentName, DateOnly AssessmentDate, decimal MaxScore);
public record CreateAssessmentDto(int TeachingAssignmentId, int AssessmentTypeId, string AssessmentName, DateOnly AssessmentDate, decimal MaxScore);
public record UpdateAssessmentDto(string? AssessmentName, DateOnly? AssessmentDate, decimal? MaxScore);
