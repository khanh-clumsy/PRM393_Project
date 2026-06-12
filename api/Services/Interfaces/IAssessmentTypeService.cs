using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IAssessmentTypeService
{
    Task<IEnumerable<AssessmentTypeDto>> GetAllAsync();
    Task<AssessmentTypeDto?> GetByIdAsync(int id);
    Task<AssessmentTypeDto> CreateAsync(CreateAssessmentTypeDto dto);
    Task<AssessmentTypeDto?> UpdateAsync(int id, UpdateAssessmentTypeDto dto);
    Task<bool> DeleteAsync(int id);
}
