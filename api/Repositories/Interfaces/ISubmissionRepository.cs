using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface ISubmissionRepository
{
    Task<Submission?> GetByIdAsync(int id);
    Task<IEnumerable<Submission>> GetByAssignmentAsync(int assignmentId);
    Task<IEnumerable<Submission>> GetByStudentAsync(int studentId);
    Task<Submission> CreateAsync(Submission submission);
    Task<Submission?> GradeAsync(int id, Submission updated);
    Task<bool> DeleteAsync(int id);
}
