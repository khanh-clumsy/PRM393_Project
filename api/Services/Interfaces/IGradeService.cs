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
    Task<AcademicTranscriptDto> GetStudentTranscriptAsync(int studentId, int academicYearId);
    Task<YearlyTranscriptDto> GetYearlyTranscriptAsync(int studentId, int academicYearId);
    Task<IEnumerable<StudentGradeEntryDto>> GetClassGradesAsync(int teachingAssignmentId, int assessmentId);
    Task SaveBulkGradesAsync(List<BulkGradeDto> grades);
    Task<IEnumerable<StudentGradeByTypeDto>> GetClassGradesByTypeAsync(int teachingAssignmentId, int assessmentTypeId);
    Task SaveBulkGradesByTypeAsync(BulkGradeByTypeDto dto, int teacherId);
}
