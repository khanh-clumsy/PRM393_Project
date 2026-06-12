using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface ISemesterService
{
    Task<IEnumerable<SemesterDto>> GetAllAsync();
    Task<IEnumerable<SemesterDto>> GetByAcademicYearAsync(int academicYearId);
    Task<SemesterDto?> GetByIdAsync(int id);
    Task<SemesterDto> CreateAsync(CreateSemesterDto dto);
    Task<SemesterDto?> UpdateAsync(int id, UpdateSemesterDto dto);
    Task<bool> DeleteAsync(int id);
}
