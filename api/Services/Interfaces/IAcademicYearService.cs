using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IAcademicYearService
{
    Task<IEnumerable<AcademicYearDto>> GetAllAsync();
    Task<AcademicYearDto?> GetByIdAsync(int id);
    Task<AcademicYearDto> CreateAsync(CreateAcademicYearDto dto);
    Task<AcademicYearDto?> UpdateAsync(int id, UpdateAcademicYearDto dto);
    Task<bool> DeleteAsync(int id);
}
