using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IClassService
{
    Task<IEnumerable<ClassDto>> GetAllAsync();
    Task<IEnumerable<ClassDto>> GetByAcademicYearAsync(int academicYearId);
    Task<ClassDto?> GetByIdAsync(int id);
    Task<ClassDto> CreateAsync(CreateClassDto dto);
    Task<ClassDto?> UpdateAsync(int id, UpdateClassDto dto);
    Task<bool> DeleteAsync(int id);
}
