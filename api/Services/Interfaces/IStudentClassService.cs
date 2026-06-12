using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IStudentClassService
{
    Task<IEnumerable<StudentClassDto>> GetByClassAsync(int classId);
    Task<IEnumerable<StudentClassDto>> GetByStudentAsync(int studentId);
    Task<StudentClassDto> CreateAsync(CreateStudentClassDto dto);
    Task<bool> DeleteAsync(int id);
}
