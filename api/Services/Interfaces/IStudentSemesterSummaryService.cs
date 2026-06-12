using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IStudentSemesterSummaryService
{
    Task<StudentSemesterSummaryDto?> GetByIdAsync(int id);
    Task<IEnumerable<StudentSemesterSummaryDto>> GetByStudentAsync(int studentId);
    Task<IEnumerable<StudentSemesterSummaryDto>> GetBySemesterAsync(int semesterId);
    Task<StudentSemesterSummaryDto> CreateAsync(CreateSemesterSummaryDto dto);
    Task<StudentSemesterSummaryDto?> UpdateAsync(int id, UpdateSemesterSummaryDto dto);
    Task<bool> DeleteAsync(int id);
}
