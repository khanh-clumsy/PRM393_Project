namespace PRM393API.DTOs;

public record TimetableDto(
    int TimetableId,
    int TeachingAssignmentId,
    DateOnly Date,
    int SlotId,
    string? RoomName,
    byte Status,
    string? Note);

public record CreateTimetableDto(
    int TeachingAssignmentId,
    DateOnly Date,
    int SlotId,
    string? RoomName,
    byte Status = 1,
    string? Note = null);

public record UpdateTimetableDto(
    DateOnly? Date,
    int? SlotId,
    string? RoomName,
    byte? Status,
    string? Note);

public record TimetableSlotDetailDto(
    int TimetableId,
    int TeachingAssignmentId,
    DateOnly Date,
    string SlotName,
    TimeOnly StartTime,
    TimeOnly EndTime,
    string? RoomName,
    int SubjectId,
    string SubjectName,
    int TeacherId,
    string TeacherName,
    int ClassId,
    string ClassName,
    byte Status,
    string? Note,
    bool IsAttendanceTaken = false);

public record TimetableTemplateDto(
    int TeachingAssignmentId,
    byte DayOfWeek,
    int SlotId,
    string? RoomName);

public record TimetableTemplateResponseDto(
    int TemplateId,
    int TeachingAssignmentId,
    byte DayOfWeek,
    int SlotId,
    string SlotName,
    TimeOnly StartTime,
    TimeOnly EndTime,
    string? RoomName,
    int SubjectId,
    string SubjectName,
    int TeacherId,
    string TeacherName,
    int ClassId,
    string ClassName,
    int SemesterId);

public record CreateTimetableTemplateDto(
    int TeachingAssignmentId,
    byte DayOfWeek,
    int SlotId,
    string? RoomName);

public record UpdateTimetableTemplateDto(
    int? TeachingAssignmentId,
    byte? DayOfWeek,
    int? SlotId,
    string? RoomName);


