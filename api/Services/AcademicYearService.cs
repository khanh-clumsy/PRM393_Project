using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class AcademicYearService(IAcademicYearRepository repo) : IAcademicYearService
{
    public async Task<IEnumerable<AcademicYearDto>> GetAllAsync()
    {
        var list = await repo.GetAllAsync();
        return list.Select(ToDto);
    }

    public async Task<AcademicYearDto?> GetByIdAsync(int id)
    {
        var year = await repo.GetByIdAsync(id);
        return year is null ? null : ToDto(year);
    }

    public async Task<AcademicYearDto> CreateAsync(CreateAcademicYearDto dto)
    {
        var year = new AcademicYear
        {
            YearName = dto.YearName,
            StartDate = dto.StartDate,
            EndDate = dto.EndDate,
            IsActive = dto.IsActive,
        };
        var created = await repo.CreateAsync(year);
        return ToDto(created);
    }

    public async Task<AcademicYearDto?> UpdateAsync(int id, UpdateAcademicYearDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.YearName = dto.YearName ?? existing.YearName;
        existing.StartDate = dto.StartDate ?? existing.StartDate;
        existing.EndDate = dto.EndDate ?? existing.EndDate;
        existing.IsActive = dto.IsActive ?? existing.IsActive;

        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) =>
        await repo.DeleteAsync(id);

    private static AcademicYearDto ToDto(AcademicYear y) =>
        new(y.AcademicYearId, y.YearName, y.StartDate, y.EndDate, y.IsActive);
}
