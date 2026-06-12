namespace PRM393API.DTOs;

public record AssessmentTypeDto(int AssessmentTypeId, string TypeName, decimal Weight);
public record CreateAssessmentTypeDto(string TypeName, decimal Weight);
public record UpdateAssessmentTypeDto(string? TypeName, decimal? Weight);
