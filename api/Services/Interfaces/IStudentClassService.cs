using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IStudentClassService
{
    Task<IEnumerable<StudentClassResponseDto>> GetByClassAsync(int classId);
    Task<IEnumerable<StudentClassResponseDto>> GetByStudentAsync(int studentId);
    Task<StudentClassResponseDto> CreateAsync(CreateStudentClassDto dto);
    Task<bool> DeleteAsync(int id);
}
