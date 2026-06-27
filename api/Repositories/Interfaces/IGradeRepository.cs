using PRM393API.DTOs;
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
    Task<AcademicTranscriptDto> GetStudentTranscriptAsync(int studentId, int academicYearId);
    Task<YearlyTranscriptDto> GetYearlyTranscriptAsync(int studentId, int academicYearId);
    Task<IEnumerable<StudentGradeEntryDto>> GetClassGradesAsync(int teachingAssignmentId, int assessmentId);
    Task SaveBulkGradesAsync(List<BulkGradeDto> grades);
    Task<IEnumerable<StudentGradeByTypeDto>> GetClassGradesByTypeAsync(int teachingAssignmentId, int assessmentTypeId);
    Task SaveBulkGradesByTypeAsync(BulkGradeByTypeDto dto, int teacherId);
}
