using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IParentStudentService
{
    Task<IEnumerable<ParentStudentDto>> GetByParentAsync(int parentId);
    Task<IEnumerable<ParentStudentDto>> GetByStudentAsync(int studentId);
    Task<ParentStudentDto?> GetByIdAsync(int id);
    Task<ParentStudentDto> CreateAsync(CreateParentStudentDto dto);
    Task<ParentStudentDto?> UpdateAsync(int id, UpdateParentStudentDto dto);
    Task<bool> DeleteAsync(int id);
}
