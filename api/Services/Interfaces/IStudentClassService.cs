using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IStudentClassService
{
    Task<IEnumerable<StudentClassResponseDto>> GetByClassAsync(int classId);
    Task<IEnumerable<StudentClassResponseDto>> GetByStudentAsync(int studentId);
    Task<StudentEnrollmentAtDateDto> GetEnrollmentAtDateAsync(int studentId, DateOnly date);
    Task<StudentClassResponseDto> CreateAsync(CreateStudentClassDto dto);
    Task<bool> DeleteAsync(int id);
}
