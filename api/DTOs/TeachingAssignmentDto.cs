namespace PRM393API.DTOs;

public record TeachingAssignmentDto(int TeachingAssignmentId, int TeacherId, int ClassId, int SubjectId, int SemesterId, string? ClassName, string? SubjectName);

public record CreateTeachingAssignmentDto(int TeacherId, int ClassId, int SubjectId, int SemesterId);
