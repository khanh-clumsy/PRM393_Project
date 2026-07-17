using Microsoft.EntityFrameworkCore;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class TimetableService(
    ITimetableRepository repo,
    Prm393dbContext db,
    IAcademicContextService academicContext) : ITimetableService
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
        var (weekStart, weekEnd) = GetWeekRange(date);
        var list = await repo.GetWeeklyByClassAsync(classId, weekStart, weekEnd);
        return list.Select(ToDetailDto);
    }

    public async Task<IEnumerable<TimetableSlotDetailDto>> GetWeeklyByTeacherAsync(int teacherId, DateOnly date)
    {
        var (weekStart, weekEnd) = GetWeekRange(date);
        var list = await repo.GetWeeklyByTeacherAsync(teacherId, weekStart, weekEnd);
        return list.Select(ToDetailDto);
    }

    public async Task<StudentWeeklyTimetableDto?> GetWeeklyByStudentAsync(int studentId, DateOnly date)
    {
        var (weekStart, weekEnd) = GetWeekRange(date);
        var enrollmentContext = await academicContext.GetStudentEnrollmentAtDateAsync(studentId, date);
        var enrollment = await ResolveStudentEnrollmentForScheduleWeekAsync(studentId, weekStart, weekEnd)
            ?? enrollmentContext.Enrollment;
        if (enrollment is null)
            return null;

        var classId = enrollment.ClassId;
        var slots = (await repo.GetWeeklyByClassAsync(classId, weekStart, weekEnd))
            .Select(ToDetailDto)
            .ToList();

        var timetableIds = slots.Select(s => s.TimetableId).ToList();
        var attendance = timetableIds.Count == 0
            ? []
            : await db.AttendanceRecords
                .Where(a => a.StudentId == studentId && timetableIds.Contains(a.TimetableId))
                .Select(a => new StudentTimetableAttendanceDto(
                    a.AttendanceId,
                    a.TimetableId,
                    a.StudentId,
                    ToDisplayAttendanceStatus(a.Status),
                    a.Note,
                    a.RecordedBy,
                    a.RecordedAt))
                .ToListAsync();

        return new StudentWeeklyTimetableDto(
            studentId,
            date,
            weekStart,
            weekEnd,
            enrollmentContext.AcademicYear,
            enrollmentContext.Semester,
            enrollment,
            slots,
            attendance);
    }

    private async Task<StudentEnrollmentDto?> ResolveStudentEnrollmentForScheduleWeekAsync(
        int studentId,
        DateOnly weekStart,
        DateOnly weekEnd)
    {
        var enrollments = await db.StudentClasses
            .Include(sc => sc.Class)
                .ThenInclude(c => c.AcademicYear)
            .Include(sc => sc.Student)
            .Where(sc => sc.StudentId == studentId)
            .OrderByDescending(sc => sc.Class.AcademicYear.StartDate)
            .ThenByDescending(sc => sc.StudentClassId)
            .ToListAsync();

        if (enrollments.Count == 0) return null;

        foreach (var enrollment in enrollments)
        {
            var hasSchedule = await db.Timetables
                .Include(t => t.TeachingAssignment)
                .AnyAsync(t => t.TeachingAssignment.ClassId == enrollment.ClassId
                            && t.Date >= weekStart
                            && t.Date <= weekEnd);
            if (hasSchedule) return ToEnrollmentDto(enrollment);
        }

        return ToEnrollmentDto(enrollments.First());
    }

    private static StudentEnrollmentDto ToEnrollmentDto(StudentClass studentClass) =>
        new(
            studentClass.StudentClassId,
            studentClass.StudentId,
            studentClass.Student?.FullName,
            studentClass.Student?.Username,
            studentClass.ClassId,
            studentClass.Class.ClassName,
            studentClass.Class.AcademicYearId,
            studentClass.Class.AcademicYear?.YearName ?? string.Empty);

    private static string ToDisplayAttendanceStatus(string status) =>
        status.Trim().ToUpperInvariant() switch
        {
            "P" or "PRESENT" => "Present",
            "A" or "ABSENT" => "Absent",
            "L" or "LATE" => "Late",
            "E" or "EXCUSED" => "Excused",
            _ => status,
        };

    private static (DateOnly weekStart, DateOnly weekEnd) GetWeekRange(DateOnly date)
    {
        int diff = ((int)date.DayOfWeek - (int)DayOfWeek.Monday + 7) % 7;
        var weekStart = date.AddDays(-diff);
        var weekEnd = weekStart.AddDays(6);
        return (weekStart, weekEnd);
    }

    public async Task<TimetableDto> CreateAsync(CreateTimetableDto dto)
    {
        await EnsureTimetableNoConflictAsync(dto.TeachingAssignmentId, dto.Date, dto.SlotId);

        var timetable = new Timetable
        {
            TeachingAssignmentId = dto.TeachingAssignmentId,
            Date = dto.Date,
            SlotId = dto.SlotId,
            RoomName = dto.RoomName,
            Status = dto.Status,
            Note = dto.Note,
        };
        return ToDto(await repo.CreateAsync(timetable));
    }

    public async Task<int> GenerateTimetablesForSemesterAsync(int semesterId, List<TimetableTemplateDto> templates)
    {
        var semester = await db.Semesters.FindAsync(semesterId);
        if (semester is null) return 0;

        var startDate = semester.StartDate;
        var endDate = semester.EndDate;

        // Xóa các lịch học cũ của semesterId này trước khi sinh mới
        var assignmentIds = await db.TeachingAssignments
            .Where(ta => ta.SemesterId == semesterId)
            .Select(ta => ta.TeachingAssignmentId)
            .ToListAsync();

        var oldTimetables = await db.Timetables
            .Where(t => assignmentIds.Contains(t.TeachingAssignmentId))
            .ToListAsync();

        var oldTimetableIds = oldTimetables.Select(t => t.TimetableId).ToList();
        var oldAttendances = await db.AttendanceRecords
            .Where(a => oldTimetableIds.Contains(a.TimetableId))
            .ToListAsync();
        db.AttendanceRecords.RemoveRange(oldAttendances);

        db.Timetables.RemoveRange(oldTimetables);
        await db.SaveChangesAsync();

        var listToInsert = new List<Timetable>();

        for (var date = startDate; date <= endDate; date = date.AddDays(1))
        {
            int dayVal = (int)date.DayOfWeek;
            byte expectedDayOfWeek = dayVal == 0 ? (byte)8 : (byte)(dayVal + 1);

            var matchingTemplates = templates.Where(t => t.DayOfWeek == expectedDayOfWeek);
            foreach (var t in matchingTemplates)
            {
                listToInsert.Add(new Timetable
                {
                    TeachingAssignmentId = t.TeachingAssignmentId,
                    Date = date,
                    SlotId = t.SlotId,
                    RoomName = t.RoomName,
                    Status = 1,
                    Note = null
                });
            }
        }

        if (listToInsert.Any())
        {
            await repo.BulkCreateAsync(listToInsert);
            return listToInsert.Count;
        }

        return 0;
    }

    public async Task<int> GenerateFromTemplatesAsync(int semesterId, int classId)
    {
        var semester = await db.Semesters.FindAsync(semesterId);
        var templates = await db.TimetableTemplates
            .Include(t => t.TeachingAssignment)
            .Where(t => t.TeachingAssignment.ClassId == classId && t.TeachingAssignment.SemesterId == semesterId)
            .ToListAsync();

        if (semester is null || !templates.Any()) return 0;

        var startDate = semester.StartDate;
        var endDate = semester.EndDate;

        var taIds = await db.TeachingAssignments
            .Where(ta => ta.ClassId == classId && ta.SemesterId == semesterId)
            .Select(ta => ta.TeachingAssignmentId)
            .ToListAsync();

        var oldTimetables = await db.Timetables
            .Where(t => taIds.Contains(t.TeachingAssignmentId))
            .ToListAsync();

        var oldTimetableIds = oldTimetables.Select(t => t.TimetableId).ToList();
        var oldAttendances = await db.AttendanceRecords
            .Where(a => oldTimetableIds.Contains(a.TimetableId))
            .ToListAsync();
        db.AttendanceRecords.RemoveRange(oldAttendances);

        db.Timetables.RemoveRange(oldTimetables);
        await db.SaveChangesAsync();

        var listToInsert = new List<Timetable>();

        for (var date = startDate; date <= endDate; date = date.AddDays(1))
        {
            int dayVal = (int)date.DayOfWeek;
            byte expectedDayOfWeek = dayVal == 0 ? (byte)8 : (byte)(dayVal + 1);

            var matching = templates.Where(t => t.DayOfWeek == expectedDayOfWeek);
            foreach (var t in matching)
            {
                listToInsert.Add(new Timetable
                {
                    TeachingAssignmentId = t.TeachingAssignmentId,
                    Date = date,
                    SlotId = t.SlotId,
                    RoomName = t.RoomName,
                    Status = 1,
                    Note = null
                });
            }
        }

        if (listToInsert.Any())
        {
            await repo.BulkCreateAsync(listToInsert);
            return listToInsert.Count;
        }

        return 0;
    }

    public async Task<int> ClearGeneratedTimetablesAsync(int semesterId, int classId)
    {
        var taIds = await db.TeachingAssignments
            .Where(ta => ta.ClassId == classId && ta.SemesterId == semesterId)
            .Select(ta => ta.TeachingAssignmentId)
            .ToListAsync();

        var oldTimetables = await db.Timetables
            .Where(t => taIds.Contains(t.TeachingAssignmentId))
            .ToListAsync();

        var oldTimetableIds = oldTimetables.Select(t => t.TimetableId).ToList();
        var oldAttendances = await db.AttendanceRecords
            .Where(a => oldTimetableIds.Contains(a.TimetableId))
            .ToListAsync();
        db.AttendanceRecords.RemoveRange(oldAttendances);

        db.Timetables.RemoveRange(oldTimetables);
        await db.SaveChangesAsync();
        return oldTimetables.Count;
    }

    public async Task<IEnumerable<TimetableTemplateResponseDto>> GetTemplatesByClassAsync(int classId, int? semesterId = null)
    {
        var query = db.TimetableTemplates
            .Include(t => t.Slot)
            .Include(t => t.TeachingAssignment).ThenInclude(ta => ta.Subject)
            .Include(t => t.TeachingAssignment).ThenInclude(ta => ta.Teacher)
            .Include(t => t.TeachingAssignment).ThenInclude(ta => ta.Class)
            .Where(t => t.TeachingAssignment.ClassId == classId);

        if (semesterId.HasValue)
        {
            query = query.Where(t => t.TeachingAssignment.SemesterId == semesterId.Value);
        }

        var list = await query.ToListAsync();
        return list.Select(ToTemplateDto);
    }

    public async Task<TimetableTemplateResponseDto> CreateTemplateAsync(CreateTimetableTemplateDto dto)
    {
        await EnsureTemplateNoConflictAsync(dto.TeachingAssignmentId, dto.DayOfWeek, dto.SlotId);

        var template = new TimetableTemplate
        {
            TeachingAssignmentId = dto.TeachingAssignmentId,
            DayOfWeek = dto.DayOfWeek,
            SlotId = dto.SlotId,
            RoomName = dto.RoomName
        };

        db.TimetableTemplates.Add(template);
        await db.SaveChangesAsync();

        var full = await db.TimetableTemplates
            .Include(t => t.Slot)
            .Include(t => t.TeachingAssignment).ThenInclude(ta => ta.Subject)
            .Include(t => t.TeachingAssignment).ThenInclude(ta => ta.Teacher)
            .Include(t => t.TeachingAssignment).ThenInclude(ta => ta.Class)
            .FirstAsync(t => t.TemplateId == template.TemplateId);

        return ToTemplateDto(full);
    }

    public async Task<TimetableTemplateResponseDto?> UpdateTemplateAsync(int id, UpdateTimetableTemplateDto dto)
    {
        var existing = await db.TimetableTemplates.FindAsync(id);
        if (existing is null) return null;

        var teachingAssignmentId = dto.TeachingAssignmentId ?? existing.TeachingAssignmentId;
        var dayOfWeek = dto.DayOfWeek ?? existing.DayOfWeek;
        var slotId = dto.SlotId ?? existing.SlotId;

        await EnsureTemplateNoConflictAsync(teachingAssignmentId, dayOfWeek, slotId, excludeTemplateId: id);

        existing.TeachingAssignmentId = teachingAssignmentId;
        existing.DayOfWeek = dayOfWeek;
        existing.SlotId = slotId;
        existing.RoomName = dto.RoomName ?? existing.RoomName;

        await db.SaveChangesAsync();

        var full = await db.TimetableTemplates
            .Include(t => t.Slot)
            .Include(t => t.TeachingAssignment).ThenInclude(ta => ta.Subject)
            .Include(t => t.TeachingAssignment).ThenInclude(ta => ta.Teacher)
            .Include(t => t.TeachingAssignment).ThenInclude(ta => ta.Class)
            .FirstAsync(t => t.TemplateId == existing.TemplateId);

        return ToTemplateDto(full);
    }

    /// <summary>
    /// Một phân công (GV + môn + lớp) chỉ được xếp 1 lần trong cùng thứ + tiết.
    /// Giáo viên cũng không được dạy 2 môn khác nhau cùng khung giờ.
    /// </summary>
    private async Task EnsureTemplateNoConflictAsync(
        int teachingAssignmentId, byte dayOfWeek, int slotId, int? excludeTemplateId = null)
    {
        var ta = await db.TeachingAssignments.FindAsync(teachingAssignmentId)
            ?? throw new InvalidOperationException("Phân công giảng dạy không tồn tại.");

        var semesterAssignmentIds = await db.TeachingAssignments
            .Where(a => a.SemesterId == ta.SemesterId)
            .Select(a => a.TeachingAssignmentId)
            .ToListAsync();

        var sameSlot = await db.TimetableTemplates
            .Include(t => t.TeachingAssignment).ThenInclude(x => x.Class)
            .Include(t => t.TeachingAssignment).ThenInclude(x => x.Subject)
            .Where(t => t.DayOfWeek == dayOfWeek && t.SlotId == slotId)
            .Where(t => semesterAssignmentIds.Contains(t.TeachingAssignmentId))
            .Where(t => excludeTemplateId == null || t.TemplateId != excludeTemplateId.Value)
            .ToListAsync();

        if (sameSlot.Any(t => t.TeachingAssignmentId == teachingAssignmentId))
        {
            throw new InvalidOperationException(
                "Phân công này đã được xếp vào tiết này trong lịch mẫu (trùng GV + môn + slot).");
        }

        var teacherConflict = sameSlot.FirstOrDefault(t => t.TeachingAssignment.TeacherId == ta.TeacherId);
        if (teacherConflict != null)
        {
            var other = teacherConflict.TeachingAssignment;
            throw new InvalidOperationException(
                $"Giáo viên đã dạy {other.Subject.SubjectName} (lớp {other.Class.ClassName}) " +
                $"cùng khung giờ {DayOfWeekLabel(dayOfWeek)} trong lịch mẫu.");
        }

        if (sameSlot.Any(t =>
                t.TeachingAssignment.ClassId == ta.ClassId &&
                t.TeachingAssignment.SubjectId == ta.SubjectId))
        {
            throw new InvalidOperationException(
                "Môn học này đã được xếp cho lớp ở tiết này trong lịch mẫu.");
        }
    }

    private static string DayOfWeekLabel(byte dayOfWeek) => dayOfWeek switch
    {
        2 => "Thứ 2",
        3 => "Thứ 3",
        4 => "Thứ 4",
        5 => "Thứ 5",
        6 => "Thứ 6",
        7 => "Thứ 7",
        8 => "Chủ Nhật",
        _ => $"Thứ {dayOfWeek}",
    };

    private async Task EnsureTimetableNoConflictAsync(
        int teachingAssignmentId, DateOnly date, int slotId, int? excludeTimetableId = null)
    {
        var ta = await db.TeachingAssignments.FindAsync(teachingAssignmentId)
            ?? throw new InvalidOperationException("Phân công giảng dạy không tồn tại.");

        var sameSlot = await db.Timetables
            .Include(t => t.TeachingAssignment)
            .Where(t => t.Date == date && t.SlotId == slotId)
            .Where(t => excludeTimetableId == null || t.TimetableId != excludeTimetableId.Value)
            .ToListAsync();

        if (sameSlot.Any(t => t.TeachingAssignmentId == teachingAssignmentId))
        {
            throw new InvalidOperationException(
                "Phân công này đã được xếp vào tiết này (trùng GV + môn + slot).");
        }

        if (sameSlot.Any(t => t.TeachingAssignment.TeacherId == ta.TeacherId))
        {
            throw new InvalidOperationException("Giáo viên đã có tiết khác cùng khung giờ.");
        }

        if (sameSlot.Any(t =>
                t.TeachingAssignment.ClassId == ta.ClassId &&
                t.TeachingAssignment.SubjectId == ta.SubjectId))
        {
            throw new InvalidOperationException("Môn học này đã được xếp cho lớp ở tiết này.");
        }
    }

    public async Task<bool> DeleteTemplateAsync(int id)
    {
        var template = await db.TimetableTemplates.FindAsync(id);
        if (template is null) return false;

        db.TimetableTemplates.Remove(template);
        await db.SaveChangesAsync();
        return true;
    }

    public async Task<TimetableDto?> UpdateAsync(int id, UpdateTimetableDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.Date = dto.Date ?? existing.Date;
        existing.SlotId = dto.SlotId ?? existing.SlotId;
        existing.RoomName = dto.RoomName ?? existing.RoomName;
        existing.Status = dto.Status ?? existing.Status;
        existing.Note = dto.Note ?? existing.Note;

        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) =>
        await repo.DeleteAsync(id);

    private static TimetableDto ToDto(Timetable t) =>
        new(t.TimetableId, t.TeachingAssignmentId, t.Date, t.SlotId, t.RoomName, t.Status, t.Note);

    private static TimetableSlotDetailDto ToDetailDto(Timetable t) => new(
        t.TimetableId,
        t.TeachingAssignmentId,
        t.Date,
        t.Slot.SlotName,
        t.Slot.StartTime,
        t.Slot.EndTime,
        t.RoomName,
        t.TeachingAssignment.SubjectId,
        t.TeachingAssignment.Subject.SubjectName,
        t.TeachingAssignment.TeacherId,
        t.TeachingAssignment.Teacher.FullName,
        t.TeachingAssignment.ClassId,
        t.TeachingAssignment.Class.ClassName,
        t.Status,
        t.Note,
        t.AttendanceRecords.Any());

    private static TimetableTemplateResponseDto ToTemplateDto(TimetableTemplate t) => new(
        t.TemplateId,
        t.TeachingAssignmentId,
        t.DayOfWeek,
        t.SlotId,
        t.Slot.SlotName,
        t.Slot.StartTime,
        t.Slot.EndTime,
        t.RoomName,
        t.TeachingAssignment.SubjectId,
        t.TeachingAssignment.Subject.SubjectName,
        t.TeachingAssignment.TeacherId,
        t.TeachingAssignment.Teacher.FullName,
        t.TeachingAssignment.ClassId,
        t.TeachingAssignment.Class.ClassName,
        t.TeachingAssignment.SemesterId);
}
