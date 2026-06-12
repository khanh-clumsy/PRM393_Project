using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IAssessmentTypeRepository
{
    Task<IEnumerable<AssessmentType>> GetAllAsync();
    Task<AssessmentType?> GetByIdAsync(int id);
    Task<AssessmentType> CreateAsync(AssessmentType type);
    Task<AssessmentType?> UpdateAsync(int id, AssessmentType updated);
    Task<bool> DeleteAsync(int id);
}
