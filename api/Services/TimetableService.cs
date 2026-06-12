using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class TimetableService(ITimetableRepository repo) : ITimetableService
{
    public async Task<IEnumerable<TimetableDto>> GetAllAsync()
    {
        var list = await repo.GetAllAsync();
        return list.Select(ToDto);
    }

    public async Task<IEnumerable<TimetableDto>> GetByAssignmentAsync(int teachingAssignmentId)
    {
        var list = await repo.GetByAssignmentAsync(teachingAssignmentId);
        return list.Select(ToDto);
    }

    public async Task<IEnumerable<TimetableDto>> GetByClassAsync(int classId)
    {
        var list = await repo.GetByClassAsync(classId);
        return list.Select(ToDto);
    }

    public async Task<TimetableDto?> GetByIdAsync(int id)
    {
        var t = await repo.GetByIdAsync(id);
        return t is null ? null : ToDto(t);
    }

    public async Task<TimetableSlotDetailDto?> GetDetailAsync(int id)
    {
        var t = await repo.GetDetailAsync(id);
        return t is null ? null : ToDetailDto(t);
    }

    public async Task<IEnumerable<TimetableSlotDetailDto>> GetWeeklyByClassAsync(int classId, DateOnly date)
    {
        var list = await repo.GetWeeklyByClassAsync(classId, date);
        return list.Select(ToDetailDto);
    }

    public async Task<IEnumerable<TimetableSlotDetailDto>> GetWeeklyByTeacherAsync(int teacherId, DateOnly date)
    {
        var list = await repo.GetWeeklyByTeacherAsync(teacherId, date);
        return list.Select(ToDetailDto);
    }

    public async Task<TimetableDto> CreateAsync(CreateTimetableDto dto)
    {
        var timetable = new Timetable
        {
            TeachingAssignmentId = dto.TeachingAssignmentId,
            DayOfWeek = dto.DayOfWeek,
            SlotId = dto.SlotId,
            RoomName = dto.RoomName,
            EffectiveFrom = dto.EffectiveFrom,
            EffectiveTo = dto.EffectiveTo,
        };
        return ToDto(await repo.CreateAsync(timetable));
    }

    public async Task<TimetableDto?> UpdateAsync(int id, UpdateTimetableDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.DayOfWeek = dto.DayOfWeek ?? existing.DayOfWeek;
        existing.SlotId = dto.SlotId ?? existing.SlotId;
        existing.RoomName = dto.RoomName ?? existing.RoomName;
        existing.EffectiveTo = dto.EffectiveTo ?? existing.EffectiveTo;

        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) =>
        await repo.DeleteAsync(id);

    private static TimetableDto ToDto(Timetable t) =>
        new(t.TimetableId, t.TeachingAssignmentId, t.DayOfWeek, t.SlotId, t.RoomName, t.EffectiveFrom, t.EffectiveTo);

    private static TimetableSlotDetailDto ToDetailDto(Timetable t) => new(
        t.TimetableId,
        t.TeachingAssignmentId,
        t.DayOfWeek,
        t.Slot.SlotName,
        t.Slot.StartTime,
        t.Slot.EndTime,
        t.RoomName,
        t.TeachingAssignment.SubjectId,
        t.TeachingAssignment.Subject.SubjectName,
        t.TeachingAssignment.TeacherId,
        t.TeachingAssignment.Teacher.FullName,
        t.TeachingAssignment.ClassId,
        t.TeachingAssignment.Class.ClassName);
}
