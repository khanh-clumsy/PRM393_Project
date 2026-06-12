namespace PRM393API.DTOs;

public record TimetableDto(
    int TimetableId,
    int TeachingAssignmentId,
    byte DayOfWeek,
    int SlotId,
    string? RoomName,
    DateOnly EffectiveFrom,
    DateOnly? EffectiveTo);

public record CreateTimetableDto(
    int TeachingAssignmentId,
    byte DayOfWeek,
    int SlotId,
    string? RoomName,
    DateOnly EffectiveFrom,
    DateOnly? EffectiveTo);

public record UpdateTimetableDto(
    byte? DayOfWeek,
    int? SlotId,
    string? RoomName,
    DateOnly? EffectiveTo);

public record TimetableSlotDetailDto(
    int TimetableId,
    int TeachingAssignmentId,
    byte DayOfWeek,
    string SlotName,
    TimeOnly StartTime,
    TimeOnly EndTime,
    string? RoomName,
    int SubjectId,
    string SubjectName,
    int TeacherId,
    string TeacherName,
    int ClassId,
    string ClassName);
