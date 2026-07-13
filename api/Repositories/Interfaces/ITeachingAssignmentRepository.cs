using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface ITeachingAssignmentRepository
{
    Task<IEnumerable<TeachingAssignment>> GetAllAsync();
    Task<IEnumerable<TeachingAssignment>> GetByTeacherAsync(int teacherId);
    Task<IEnumerable<TeachingAssignment>> GetByClassAsync(int classId);
    Task<IEnumerable<TeachingAssignment>> GetBySemesterAsync(int semesterId);
    Task<IEnumerable<TeachingAssignment>> GetByDepartmentAsync(int departmentId);
    Task<TeachingAssignment?> GetByIdAsync(int id);
    Task<TeachingAssignment> CreateAsync(TeachingAssignment ta);
    Task<TeachingAssignment?> UpdateAsync(TeachingAssignment ta);
    Task<bool> DeleteAsync(int id);
}
