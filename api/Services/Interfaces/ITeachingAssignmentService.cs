using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface ITeachingAssignmentService
{
    Task<IEnumerable<TeachingAssignmentDto>> GetAllAsync();
    Task<IEnumerable<TeachingAssignmentDto>> GetByTeacherAsync(int teacherId);
    Task<IEnumerable<TeachingAssignmentDto>> GetByClassAsync(int classId);
    Task<IEnumerable<TeachingAssignmentDto>> GetBySemesterAsync(int semesterId);
    Task<TeachingAssignmentDto?> GetByIdAsync(int id);
    Task<TeachingAssignmentDto> CreateAsync(CreateTeachingAssignmentDto dto);
    Task<TeachingAssignmentDto?> UpdateAsync(int id, UpdateTeachingAssignmentDto dto);
    Task<bool> DeleteAsync(int id);
}
