namespace PRM393API.DTOs;

public record TimetableSlotDto(int SlotId, string SlotName, TimeOnly StartTime, TimeOnly EndTime);

public record CreateTimetableSlotDto(string SlotName, TimeOnly StartTime, TimeOnly EndTime);

public record UpdateTimetableSlotDto(string? SlotName, TimeOnly? StartTime, TimeOnly? EndTime);
