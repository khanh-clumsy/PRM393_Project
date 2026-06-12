using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IStudentYearlySummaryService
{
    Task<StudentYearlySummaryDto?> GetByIdAsync(int id);
    Task<IEnumerable<StudentYearlySummaryDto>> GetByStudentAsync(int studentId);
    Task<IEnumerable<StudentYearlySummaryDto>> GetByYearAsync(int academicYearId);
    Task<StudentYearlySummaryDto> CreateAsync(CreateYearlySummaryDto dto);
    Task<StudentYearlySummaryDto?> UpdateAsync(int id, UpdateYearlySummaryDto dto);
    Task<bool> DeleteAsync(int id);
}
