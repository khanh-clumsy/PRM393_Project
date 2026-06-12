using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IAssignmentService
{
    Task<IEnumerable<AssignmentDto>> GetAllAsync();
    Task<AssignmentDto?> GetByIdAsync(int id);
    Task<IEnumerable<AssignmentDto>> GetByTeachingAssignmentAsync(int teachingAssignmentId);
    Task<AssignmentDto> CreateAsync(CreateAssignmentDto dto);
    Task<AssignmentDto?> UpdateAsync(int id, UpdateAssignmentDto dto);
    Task<bool> DeleteAsync(int id);
}
