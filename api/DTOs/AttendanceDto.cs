namespace PRM393API.DTOs;

public record AttendanceDto(
    int AttendanceId,
    int TimetableId,
    int StudentId,
    DateOnly AttendanceDate,
    string Status,
    string? Note,
    int RecordedBy,
    DateTime RecordedAt);

public record CreateAttendanceDto(
    int TimetableId,
    int StudentId,
    DateOnly AttendanceDate,
    string Status,
    string? Note,
    int RecordedBy);

public record UpdateAttendanceDto(string? Status, string? Note);
