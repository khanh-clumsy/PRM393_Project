using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IStudentClassRepository
{
    Task<IEnumerable<StudentClass>> GetByClassAsync(int classId);
    Task<IEnumerable<StudentClass>> GetByStudentAsync(int studentId);
    Task<StudentClass?> GetByIdAsync(int id);
    Task<StudentClass> CreateAsync(StudentClass sc);
    Task<bool> DeleteAsync(int id);
}
