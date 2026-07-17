using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IAttendanceService
{
    Task<IEnumerable<AttendanceDto>> GetByStudentAsync(int studentId);
    Task<SemesterAttendanceSummaryDto> GetStudentAttendanceSummaryAsync(int studentId, int semesterId);
    Task<IEnumerable<AttendanceDto>> GetByTimetableAsync(int timetableId);
    Task<IEnumerable<AttendanceDto>> GetByTimetableForCurrentUserAsync(int timetableId, int currentUserId, string role);
    Task<IEnumerable<AttendanceDto>> GetByStudentAndDateAsync(int studentId, DateOnly date);
    Task<AttendanceDto?> GetByIdAsync(int id);
    Task<AttendanceDto?> GetByIdForCurrentUserAsync(int id, int currentUserId, string role);
    Task<AttendanceDto> CreateAsync(CreateAttendanceDto dto);
    Task<AttendanceDto> CreateForCurrentUserAsync(CreateAttendanceDto dto, int currentUserId, string role);
    Task<AttendanceDto> CreateForTeacherAsync(CreateAttendanceDto dto, int teacherId);
    Task<IEnumerable<AttendanceDto>> BulkCreateAsync(IEnumerable<CreateAttendanceDto> dtos);
    Task<IEnumerable<AttendanceDto>> BulkCreateForCurrentUserAsync(IEnumerable<CreateAttendanceDto> dtos, int currentUserId, string role);
    Task<IEnumerable<AttendanceDto>> BulkUpdateAsync(IEnumerable<BulkUpdateAttendanceDto> dtos);
    Task<IEnumerable<AttendanceDto>> BulkUpdateForCurrentUserAsync(IEnumerable<BulkUpdateAttendanceDto> dtos, int currentUserId, string role);
    Task<AttendanceDto?> UpdateAsync(int id, UpdateAttendanceDto dto);
    Task<AttendanceDto?> UpdateForCurrentUserAsync(int id, UpdateAttendanceDto dto, int currentUserId, string role);
    Task<bool> DeleteAsync(int id);
    Task<bool> DeleteForCurrentUserAsync(int id, int currentUserId, string role);
}
