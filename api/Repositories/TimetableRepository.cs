using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class TimetableRepository(Prm393dbContext db) : ITimetableRepository
{
    public async Task<IEnumerable<Timetable>> GetAllAsync() =>
        await db.Timetables.ToListAsync();

    public async Task<IEnumerable<Timetable>> GetByAssignmentAsync(int teachingAssignmentId) =>
        await db.Timetables.Where(t => t.TeachingAssignmentId == teachingAssignmentId).ToListAsync();

    public async Task<IEnumerable<Timetable>> GetByClassAsync(int classId) =>
        await db.Timetables
            .Include(t => t.TeachingAssignment)
            .Where(t => t.TeachingAssignment.ClassId == classId)
            .ToListAsync();

    public async Task<Timetable?> GetByIdAsync(int id) =>
        await db.Timetables.FindAsync(id);

    public async Task<Timetable?> GetDetailAsync(int id) =>
        await db.Timetables
            .Include(t => t.Slot)
            .Include(t => t.TeachingAssignment)
                .ThenInclude(ta => ta.Subject)
            .Include(t => t.TeachingAssignment)
                .ThenInclude(ta => ta.Teacher)
            .Include(t => t.TeachingAssignment)
                .ThenInclude(ta => ta.Class)
            .FirstOrDefaultAsync(t => t.TimetableId == id);

    public async Task<IEnumerable<Timetable>> GetWeeklyByClassAsync(int classId, DateOnly weekStart, DateOnly weekEnd) =>
        await db.Timetables
            .Include(t => t.Slot)
            .Include(t => t.TeachingAssignment).ThenInclude(ta => ta.Subject)
            .Include(t => t.TeachingAssignment).ThenInclude(ta => ta.Teacher)
            .Include(t => t.TeachingAssignment).ThenInclude(ta => ta.Class)
            .Where(t => t.TeachingAssignment.ClassId == classId
                     && t.EffectiveFrom <= weekEnd
                     && (t.EffectiveTo == null || t.EffectiveTo >= weekStart))
            .OrderBy(t => t.DayOfWeek)
            .ThenBy(t => t.Slot.StartTime)
            .ToListAsync();

    public async Task<IEnumerable<Timetable>> GetWeeklyByTeacherAsync(int teacherId, DateOnly weekStart, DateOnly weekEnd) =>
        await db.Timetables
            .Include(t => t.Slot)
            .Include(t => t.TeachingAssignment).ThenInclude(ta => ta.Subject)
            .Include(t => t.TeachingAssignment).ThenInclude(ta => ta.Teacher)
            .Include(t => t.TeachingAssignment).ThenInclude(ta => ta.Class)
            .Where(t => t.TeachingAssignment.TeacherId == teacherId
                     && t.EffectiveFrom <= weekEnd
                     && (t.EffectiveTo == null || t.EffectiveTo >= weekStart))
            .OrderBy(t => t.DayOfWeek)
            .ThenBy(t => t.Slot.StartTime)
            .ToListAsync();

    public async Task<Timetable> CreateAsync(Timetable timetable)
    {
        db.Timetables.Add(timetable);
        await db.SaveChangesAsync();
        return timetable;
    }

    public async Task<Timetable?> UpdateAsync(int id, Timetable updated)
    {
        var timetable = await db.Timetables.FindAsync(id);
        if (timetable is null) return null;

        timetable.DayOfWeek = updated.DayOfWeek;
        timetable.SlotId = updated.SlotId;
        timetable.RoomName = updated.RoomName;
        timetable.EffectiveTo = updated.EffectiveTo;
        await db.SaveChangesAsync();
        return timetable;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var timetable = await db.Timetables.FindAsync(id);
        if (timetable is null) return false;

        db.Timetables.Remove(timetable);
        await db.SaveChangesAsync();
        return true;
    }
}
