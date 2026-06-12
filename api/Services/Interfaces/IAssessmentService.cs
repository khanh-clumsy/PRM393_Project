using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IAssessmentService
{
    Task<IEnumerable<AssessmentDto>> GetAllAsync();
    Task<AssessmentDto?> GetByIdAsync(int id);
    Task<IEnumerable<AssessmentDto>> GetByTeachingAssignmentAsync(int teachingAssignmentId);
    Task<AssessmentDto> CreateAsync(CreateAssessmentDto dto);
    Task<AssessmentDto?> UpdateAsync(int id, UpdateAssessmentDto dto);
    Task<bool> DeleteAsync(int id);
}
