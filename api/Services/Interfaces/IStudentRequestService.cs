using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IStudentRequestService
{
    Task<StudentRequestDto?> GetByIdAsync(int id);
    Task<IEnumerable<StudentRequestDto>> GetByStudentAsync(int studentId);
    Task<IEnumerable<StudentRequestDto>> GetPendingAsync();
    Task<IEnumerable<StudentRequestDto>> GetPendingForTeacherAsync(int teacherId);
    Task<StudentRequestDto> CreateAsync(CreateStudentRequestDto dto);
    Task<StudentRequestDto> CreateForCurrentUserAsync(CreateStudentRequestDto dto, int currentUserId, string role);
    Task<StudentRequestDto?> ReviewAsync(int id, ReviewStudentRequestDto dto);
    Task<bool> DeleteAsync(int id);
}
