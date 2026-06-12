using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IStudentRequestRepository
{
    Task<StudentRequest?> GetByIdAsync(int id);
    Task<IEnumerable<StudentRequest>> GetByStudentAsync(int studentId);
    Task<IEnumerable<StudentRequest>> GetPendingAsync();
    Task<StudentRequest> CreateAsync(StudentRequest request);
    Task<StudentRequest?> ReviewAsync(int id, StudentRequest updated);
    Task<bool> DeleteAsync(int id);
}
