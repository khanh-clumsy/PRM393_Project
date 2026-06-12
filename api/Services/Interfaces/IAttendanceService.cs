using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IAttendanceService
{
    Task<IEnumerable<AttendanceDto>> GetByStudentAsync(int studentId);
    Task<IEnumerable<AttendanceDto>> GetByTimetableAsync(int timetableId);
    Task<IEnumerable<AttendanceDto>> GetByStudentAndDateAsync(int studentId, DateOnly date);
    Task<AttendanceDto?> GetByIdAsync(int id);
    Task<AttendanceDto> CreateAsync(CreateAttendanceDto dto);
    Task<AttendanceDto?> UpdateAsync(int id, UpdateAttendanceDto dto);
    Task<bool> DeleteAsync(int id);
}
