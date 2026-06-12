using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IStudentYearlySummaryRepository
{
    Task<StudentYearlySummary?> GetByIdAsync(int id);
    Task<IEnumerable<StudentYearlySummary>> GetByStudentAsync(int studentId);
    Task<IEnumerable<StudentYearlySummary>> GetByYearAsync(int academicYearId);
    Task<StudentYearlySummary> CreateAsync(StudentYearlySummary summary);
    Task<StudentYearlySummary?> UpdateAsync(int id, StudentYearlySummary updated);
    Task<bool> DeleteAsync(int id);
}
