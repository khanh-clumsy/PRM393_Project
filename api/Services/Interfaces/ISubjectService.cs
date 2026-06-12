using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface ISubjectService
{
    Task<IEnumerable<SubjectDto>> GetAllAsync();
    Task<SubjectDto?> GetByIdAsync(int id);
    Task<SubjectDto> CreateAsync(CreateSubjectDto dto);
    Task<SubjectDto?> UpdateAsync(int id, UpdateSubjectDto dto);
    Task<bool> DeleteAsync(int id);
}
