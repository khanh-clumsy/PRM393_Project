namespace PRM393API.DTOs;

public record AssignmentDto(int AssignmentId, int TeachingAssignmentId, string Title, string? Description, string? AttachmentUrl, DateTime DueDate, int CreatedBy, DateTime CreatedAt);
public record CreateAssignmentDto(int TeachingAssignmentId, string Title, string? Description, string? AttachmentUrl, DateTime DueDate, int CreatedBy);
public record UpdateAssignmentDto(string? Title, string? Description, string? AttachmentUrl, DateTime? DueDate);
