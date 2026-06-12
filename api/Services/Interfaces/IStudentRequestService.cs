using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IStudentRequestService
{
    Task<StudentRequestDto?> GetByIdAsync(int id);
    Task<IEnumerable<StudentRequestDto>> GetByStudentAsync(int studentId);
    Task<IEnumerable<StudentRequestDto>> GetPendingAsync();
    Task<StudentRequestDto> CreateAsync(CreateStudentRequestDto dto);
    Task<StudentRequestDto?> ReviewAsync(int id, ReviewStudentRequestDto dto);
    Task<bool> DeleteAsync(int id);
}
