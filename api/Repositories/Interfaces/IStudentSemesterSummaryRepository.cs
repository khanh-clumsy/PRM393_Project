using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IStudentSemesterSummaryRepository
{
    Task<StudentSemesterSummary?> GetByIdAsync(int id);
    Task<IEnumerable<StudentSemesterSummary>> GetByStudentAsync(int studentId);
    Task<IEnumerable<StudentSemesterSummary>> GetBySemesterAsync(int semesterId);
    Task<StudentSemesterSummary> CreateAsync(StudentSemesterSummary summary);
    Task<StudentSemesterSummary?> UpdateAsync(int id, StudentSemesterSummary updated);
    Task<bool> DeleteAsync(int id);
}
