using PRM393API.Models;
using PRM393API.DTOs;

namespace PRM393API.Repositories.Interfaces;

public interface IAttendanceRepository
{
    Task<IEnumerable<AttendanceRecord>> GetByStudentAsync(int studentId);
    Task<SemesterAttendanceSummaryDto> GetStudentAttendanceSummaryAsync(int studentId, int semesterId);
    Task<IEnumerable<AttendanceRecord>> GetByTimetableAsync(int timetableId);
    Task<IEnumerable<AttendanceRecord>> GetByStudentAndDateAsync(int studentId, DateOnly date);
    Task<AttendanceRecord?> GetByIdAsync(int id);
    Task<AttendanceRecord> CreateAsync(AttendanceRecord record);
    Task<IEnumerable<AttendanceRecord>> BulkCreateAsync(IEnumerable<AttendanceRecord> records);
    Task<IEnumerable<AttendanceRecord>> BulkUpdateAsync(IEnumerable<(int id, string status, string? note)> updates);
    Task<AttendanceRecord?> UpdateAsync(int id, AttendanceRecord record);
    Task<bool> DeleteAsync(int id);
}
