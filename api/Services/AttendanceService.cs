using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class AttendanceService(IAttendanceRepository repo) : IAttendanceService
{
    public async Task<IEnumerable<AttendanceDto>> GetByStudentAsync(int studentId)
    {
        var list = await repo.GetByStudentAsync(studentId);
        return list.Select(ToDto);
    }

    public async Task<IEnumerable<AttendanceDto>> GetByTimetableAsync(int timetableId)
    {
        var list = await repo.GetByTimetableAsync(timetableId);
        return list.Select(ToDto);
    }

    public async Task<IEnumerable<AttendanceDto>> GetByStudentAndDateAsync(int studentId, DateOnly date)
    {
        var list = await repo.GetByStudentAndDateAsync(studentId, date);
        return list.Select(ToDto);
    }

    public async Task<AttendanceDto?> GetByIdAsync(int id)
    {
        var record = await repo.GetByIdAsync(id);
        return record is null ? null : ToDto(record);
    }

    public async Task<AttendanceDto> CreateAsync(CreateAttendanceDto dto)
    {
        var record = new AttendanceRecord
        {
            TimetableId = dto.TimetableId,
            StudentId = dto.StudentId,
            Status = ToStorageStatus(dto.Status),
            Note = dto.Note,
            RecordedBy = dto.RecordedBy,
            RecordedAt = DateTime.UtcNow,
        };
        return ToDto(await repo.CreateAsync(record));
    }

    public async Task<IEnumerable<AttendanceDto>> BulkCreateAsync(IEnumerable<CreateAttendanceDto> dtos)
    {
        var records = dtos.Select(dto => new AttendanceRecord
        {
            TimetableId = dto.TimetableId,
            StudentId = dto.StudentId,
            Status = ToStorageStatus(dto.Status),
            Note = dto.Note,
            RecordedBy = dto.RecordedBy,
            RecordedAt = DateTime.UtcNow,
        });
        var created = await repo.BulkCreateAsync(records);
        return created.Select(ToDto);
    }

    public async Task<IEnumerable<AttendanceDto>> BulkUpdateAsync(IEnumerable<BulkUpdateAttendanceDto> dtos)
    {
        var updates = dtos.Select(d => (d.AttendanceId, ToStorageStatus(d.Status), d.Note));
        var updated = await repo.BulkUpdateAsync(updates);
        return updated.Select(ToDto);
    }

    public async Task<AttendanceDto?> UpdateAsync(int id, UpdateAttendanceDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.Status = dto.Status is null ? existing.Status : ToStorageStatus(dto.Status);
        existing.Note = dto.Note ?? existing.Note;

        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) =>
        await repo.DeleteAsync(id);

    public async Task<SemesterAttendanceSummaryDto> GetStudentAttendanceSummaryAsync(int studentId, int semesterId) =>
        await repo.GetStudentAttendanceSummaryAsync(studentId, semesterId);

    private static AttendanceDto ToDto(AttendanceRecord a) =>
        new(a.AttendanceId, a.TimetableId, a.StudentId, ToDisplayStatus(a.Status), a.Note, a.RecordedBy, a.RecordedAt);

    private static string ToStorageStatus(string status) =>
        status.Trim().ToUpperInvariant() switch
        {
            "P" or "PRESENT" => "P",
            "A" or "ABSENT" => "A",
            "L" or "LATE" => "L",
            "E" or "EXCUSED" => "E",
            _ => throw new ArgumentException($"Trạng thái điểm danh không hợp lệ: {status}")
        };

    private static string ToDisplayStatus(string status) =>
        status.Trim().ToUpperInvariant() switch
        {
            "P" => "Present",
            "A" => "Absent",
            "L" => "Late",
            "E" => "Excused",
            _ => status
        };
}
