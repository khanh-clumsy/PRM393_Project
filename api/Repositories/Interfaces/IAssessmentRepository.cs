using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IAssessmentRepository
{
    Task<IEnumerable<Assessment>> GetAllAsync();
    Task<Assessment?> GetByIdAsync(int id);
    Task<IEnumerable<Assessment>> GetByTeachingAssignmentAsync(int teachingAssignmentId);
    Task<Assessment> CreateAsync(Assessment assessment);
    Task<Assessment?> UpdateAsync(int id, Assessment updated);
    Task<bool> DeleteAsync(int id);
}
