using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class AttendanceRepository(Prm393dbContext db) : IAttendanceRepository
{
    public async Task<IEnumerable<AttendanceRecord>> GetByStudentAsync(int studentId) =>
        await db.AttendanceRecords.Where(a => a.StudentId == studentId).ToListAsync();

    public async Task<IEnumerable<AttendanceRecord>> GetByTimetableAsync(int timetableId) =>
        await db.AttendanceRecords.Where(a => a.TimetableId == timetableId).ToListAsync();

    public async Task<IEnumerable<AttendanceRecord>> GetByStudentAndDateAsync(int studentId, DateOnly date) =>
        await db.AttendanceRecords
            .Where(a => a.StudentId == studentId && a.AttendanceDate == date)
            .ToListAsync();

    public async Task<AttendanceRecord?> GetByIdAsync(int id) =>
        await db.AttendanceRecords.FindAsync(id);

    public async Task<AttendanceRecord> CreateAsync(AttendanceRecord record)
    {
        db.AttendanceRecords.Add(record);
        await db.SaveChangesAsync();
        return record;
    }

    public async Task<AttendanceRecord?> UpdateAsync(int id, AttendanceRecord updated)
    {
        var record = await db.AttendanceRecords.FindAsync(id);
        if (record is null) return null;

        record.Status = updated.Status;
        record.Note = updated.Note;
        await db.SaveChangesAsync();
        return record;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var record = await db.AttendanceRecords.FindAsync(id);
        if (record is null) return false;

        db.AttendanceRecords.Remove(record);
        await db.SaveChangesAsync();
        return true;
    }
}
