using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IGradeService
{
    Task<GradeDto?> GetByIdAsync(int id);
    Task<IEnumerable<GradeDto>> GetByAssessmentAsync(int assessmentId);
    Task<IEnumerable<GradeDto>> GetByStudentAsync(int studentId);
    Task<GradeDto> CreateAsync(CreateGradeDto dto);
    Task<GradeDto?> UpdateAsync(int id, UpdateGradeDto dto);
    Task<bool> DeleteAsync(int id);
}
