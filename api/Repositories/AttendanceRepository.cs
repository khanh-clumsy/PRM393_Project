using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.DTOs;

namespace PRM393API.Repositories;

public class AttendanceRepository(Prm393dbContext db) : IAttendanceRepository
{
    public async Task<IEnumerable<AttendanceRecord>> GetByStudentAsync(int studentId) =>
        await db.AttendanceRecords.Where(a => a.StudentId == studentId).ToListAsync();

    public async Task<IEnumerable<AttendanceRecord>> GetByTimetableAsync(int timetableId) =>
        await db.AttendanceRecords.Where(a => a.TimetableId == timetableId).ToListAsync();

    public async Task<IEnumerable<AttendanceRecord>> GetByStudentAndDateAsync(int studentId, DateOnly date) =>
        await db.AttendanceRecords
            .Include(a => a.Timetable)
            .Where(a => a.StudentId == studentId && a.Timetable.Date == date)
            .ToListAsync();

    public async Task<AttendanceRecord?> GetByIdAsync(int id) =>
        await db.AttendanceRecords.FindAsync(id);

    public async Task<AttendanceRecord> CreateAsync(AttendanceRecord record)
    {
        db.AttendanceRecords.Add(record);
        await db.SaveChangesAsync();
        return record;
    }

    public async Task<IEnumerable<AttendanceRecord>> BulkCreateAsync(IEnumerable<AttendanceRecord> records)
    {
        var list = records.ToList();
        db.AttendanceRecords.AddRange(list);
        await db.SaveChangesAsync();
        return list;
    }

    public async Task<IEnumerable<AttendanceRecord>> BulkUpdateAsync(IEnumerable<(int id, string status, string? note)> updates)
    {
        var ids = updates.Select(u => u.id).ToList();
        var records = await db.AttendanceRecords.Where(a => ids.Contains(a.AttendanceId)).ToListAsync();
        var map = records.ToDictionary(a => a.AttendanceId);

        foreach (var (id, status, note) in updates)
        {
            if (!map.TryGetValue(id, out var record)) continue;
            record.Status = status;
            record.Note = note;
        }

        await db.SaveChangesAsync();
        return records;
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

    public async Task<SemesterAttendanceSummaryDto> GetStudentAttendanceSummaryAsync(int studentId, int semesterId)
    {
        var emptyResult = new SemesterAttendanceSummaryDto();
        var semester = await db.Semesters.FindAsync(semesterId);
        if (semester == null) return emptyResult;

        var studentClass = await db.StudentClasses
            .Include(sc => sc.Class)
            .FirstOrDefaultAsync(sc => sc.StudentId == studentId && sc.Class.AcademicYearId == semester.AcademicYearId);

        if (studentClass == null) return emptyResult;

        var classId = studentClass.ClassId;

        // Lấy tất cả teaching assignments thuộc class & semester đó
        var teachingAssignments = await db.TeachingAssignments
            .Include(ta => ta.Subject)
            .Where(ta => ta.ClassId == classId && ta.SemesterId == semesterId)
            .ToListAsync();

        var teachingAssignmentIds = teachingAssignments.Select(ta => ta.TeachingAssignmentId).ToList();

        // Lấy tất cả timetables tương ứng (loại bỏ Status = 3 - Cancelled)
        var timetables = await db.Timetables
            .Include(t => t.Slot)
            .Where(t => teachingAssignmentIds.Contains(t.TeachingAssignmentId) && t.Status != 3)
            .ToListAsync();

        var timetableIds = timetables.Select(t => t.TimetableId).ToList();

        // Lấy tất cả attendance records của học sinh cho các timetables này
        var attendanceRecords = await db.AttendanceRecords
            .Where(ar => ar.StudentId == studentId && timetableIds.Contains(ar.TimetableId))
            .ToListAsync();

        var attendanceMap = attendanceRecords.ToDictionary(ar => ar.TimetableId);

        var result = new List<StudentSubjectAttendanceDto>();

        foreach (var assignment in teachingAssignments)
        {
            var assignmentTimetables = timetables
                .Where(t => t.TeachingAssignmentId == assignment.TeachingAssignmentId)
                .OrderBy(t => t.Date)
                .ThenBy(t => t.Slot.StartTime)
                .ToList();

            var details = new List<StudentAttendanceDetailDto>();
            int present = 0, absent = 0, late = 0, excused = 0;

            foreach (var timetable in assignmentTimetables)
            {
                string status = "Not Checked";
                string? note = null;

                if (attendanceMap.TryGetValue(timetable.TimetableId, out var ar))
                {
                    status = ToDisplayStatus(ar.Status);
                    note = ar.Note;

                    switch (ToStorageStatus(ar.Status))
                    {
                        case "P":
                            present++;
                            break;
                        case "A":
                            absent++;
                            break;
                        case "L":
                            late++;
                            break;
                        case "E":
                            excused++;
                            break;
                    }
                }
                else
                {
                    var today = DateOnly.FromDateTime(DateTime.Today);
                    if (timetable.Date > today)
                    {
                        status = "Future";
                    }
                }

                details.Add(new StudentAttendanceDetailDto
                {
                    TimetableId = timetable.TimetableId,
                    Date = timetable.Date,
                    SlotName = timetable.Slot.SlotName,
                    RoomName = timetable.RoomName,
                    Status = status,
                    Note = note
                });
            }

            result.Add(new StudentSubjectAttendanceDto
            {
                SubjectId = assignment.SubjectId,
                SubjectName = assignment.Subject.SubjectName,
                PresentCount = present,
                AbsentCount = absent,
                LateCount = late,
                ExcusedCount = excused,
                TotalCount = assignmentTimetables.Count,
                Details = details
            });
        }

        var totalPresent = result.Sum(s => s.PresentCount);
        var totalAbsent = result.Sum(s => s.AbsentCount);
        var totalLate = result.Sum(s => s.LateCount);
        var totalExcused = result.Sum(s => s.ExcusedCount);

        return new SemesterAttendanceSummaryDto
        {
            TotalPresent = totalPresent,
            TotalAbsent = totalAbsent,
            TotalLate = totalLate,
            TotalExcused = totalExcused,
            Subjects = result
        };
    }

    private static string ToStorageStatus(string status) =>
        status.Trim().ToUpperInvariant() switch
        {
            "P" or "PRESENT" => "P",
            "A" or "ABSENT" => "A",
            "L" or "LATE" => "L",
            "E" or "EXCUSED" => "E",
            _ => status
        };

    private static string ToDisplayStatus(string status) =>
        ToStorageStatus(status) switch
        {
            "P" => "Present",
            "A" => "Absent",
            "L" => "Late",
            "E" => "Excused",
            _ => status
        };
}
