using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IAttendanceRepository
{
    Task<IEnumerable<AttendanceRecord>> GetByStudentAsync(int studentId);
    Task<IEnumerable<AttendanceRecord>> GetByTimetableAsync(int timetableId);
    Task<IEnumerable<AttendanceRecord>> GetByStudentAndDateAsync(int studentId, DateOnly date);
    Task<AttendanceRecord?> GetByIdAsync(int id);
    Task<AttendanceRecord> CreateAsync(AttendanceRecord record);
    Task<AttendanceRecord?> UpdateAsync(int id, AttendanceRecord record);
    Task<bool> DeleteAsync(int id);
}
