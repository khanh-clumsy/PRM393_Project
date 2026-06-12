namespace PRM393API.DTOs;

public record StudentRequestDto(int StudentRequestId, int StudentId, int RequestedBy, DateOnly LeaveDate, string Reason, string? AttachmentUrl, string Status, int? ReviewedBy, DateTime? ReviewedAt, string? ReviewNote, DateTime CreatedAt);
public record CreateStudentRequestDto(int StudentId, int RequestedBy, DateOnly LeaveDate, string Reason, string? AttachmentUrl);
public record ReviewStudentRequestDto(string Status, int ReviewedBy, string? ReviewNote);
