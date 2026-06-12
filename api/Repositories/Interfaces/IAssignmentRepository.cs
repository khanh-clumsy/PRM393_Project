using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IAssignmentRepository
{
    Task<IEnumerable<Assignment>> GetAllAsync();
    Task<Assignment?> GetByIdAsync(int id);
    Task<IEnumerable<Assignment>> GetByTeachingAssignmentAsync(int teachingAssignmentId);
    Task<Assignment> CreateAsync(Assignment assignment);
    Task<Assignment?> UpdateAsync(int id, Assignment updated);
    Task<bool> SoftDeleteAsync(int id);
}
