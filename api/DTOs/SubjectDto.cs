namespace PRM393API.DTOs;

public record SubjectDto(int SubjectId, string SubjectCode, string SubjectName, bool IsActive);

public record CreateSubjectDto(string SubjectCode, string SubjectName, bool IsActive = true);

public record UpdateSubjectDto(string? SubjectCode, string? SubjectName, bool? IsActive);
