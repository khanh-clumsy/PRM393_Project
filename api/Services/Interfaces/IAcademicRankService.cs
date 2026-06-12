using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IAcademicRankService
{
    Task<IEnumerable<AcademicRankDto>> GetAllAsync();
    Task<AcademicRankDto?> GetByIdAsync(int id);
    Task<AcademicRankDto> CreateAsync(CreateAcademicRankDto dto);
    Task<AcademicRankDto?> UpdateAsync(int id, UpdateAcademicRankDto dto);
    Task<bool> DeleteAsync(int id);
}
