using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IGradeRepository
{
    Task<Grade?> GetByIdAsync(int id);
    Task<IEnumerable<Grade>> GetByAssessmentAsync(int assessmentId);
    Task<IEnumerable<Grade>> GetByStudentAsync(int studentId);
    Task<Grade> CreateAsync(Grade grade);
    Task<Grade?> UpdateAsync(int id, Grade updated);
    Task<bool> DeleteAsync(int id);
}
