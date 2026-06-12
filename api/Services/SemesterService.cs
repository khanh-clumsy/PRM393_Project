using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class SemesterService(ISemesterRepository repo) : ISemesterService
{
    public async Task<IEnumerable<SemesterDto>> GetAllAsync()
    {
        var list = await repo.GetAllAsync();
        return list.Select(ToDto);
    }

    public async Task<IEnumerable<SemesterDto>> GetByAcademicYearAsync(int academicYearId)
    {
        var list = await repo.GetByAcademicYearAsync(academicYearId);
        return list.Select(ToDto);
    }

    public async Task<SemesterDto?> GetByIdAsync(int id)
    {
        var s = await repo.GetByIdAsync(id);
        return s is null ? null : ToDto(s);
    }

    public async Task<SemesterDto> CreateAsync(CreateSemesterDto dto)
    {
        var semester = new Semester
        {
            AcademicYearId = dto.AcademicYearId,
            SemesterName = dto.SemesterName,
            StartDate = dto.StartDate,
            EndDate = dto.EndDate,
        };
        var created = await repo.CreateAsync(semester);
        return ToDto(created);
    }

    public async Task<SemesterDto?> UpdateAsync(int id, UpdateSemesterDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.SemesterName = dto.SemesterName ?? existing.SemesterName;
        existing.StartDate = dto.StartDate ?? existing.StartDate;
        existing.EndDate = dto.EndDate ?? existing.EndDate;

        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) =>
        await repo.DeleteAsync(id);

    private static SemesterDto ToDto(Semester s) =>
        new(s.SemesterId, s.AcademicYearId, s.SemesterName, s.StartDate, s.EndDate);
}
