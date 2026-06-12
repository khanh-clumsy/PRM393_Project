using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface ISubmissionService
{
    Task<SubmissionDto?> GetByIdAsync(int id);
    Task<IEnumerable<SubmissionDto>> GetByAssignmentAsync(int assignmentId);
    Task<IEnumerable<SubmissionDto>> GetByStudentAsync(int studentId);
    Task<SubmissionDto> CreateAsync(CreateSubmissionDto dto);
    Task<SubmissionDto?> GradeAsync(int id, GradeSubmissionDto dto);
    Task<bool> DeleteAsync(int id);
}
