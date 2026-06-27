using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class AcademicYearService(IAcademicYearRepository repo, ISemesterRepository semesterRepo) : IAcademicYearService
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

        // Auto-create Semesters
        var startYear = created.StartDate.Year;
        var endYear = created.EndDate.Year;
        
        // Học kỳ 1: 01/09 (năm bắt đầu) đến 15/01 (năm kết thúc)
        var sem1Start = new DateOnly(startYear, 9, 1);
        var sem1End = new DateOnly(endYear, 1, 15);
        
        // Học kỳ 2: 16/01 (năm kết thúc) đến 31/05 (năm kết thúc)
        var sem2Start = new DateOnly(endYear, 1, 16);
        var sem2End = new DateOnly(endYear, 5, 31);

        await semesterRepo.CreateAsync(new Semester
        {
            AcademicYearId = created.AcademicYearId,
            SemesterName = "Học kỳ 1",
            StartDate = sem1Start,
            EndDate = sem1End
        });

        await semesterRepo.CreateAsync(new Semester
        {
            AcademicYearId = created.AcademicYearId,
            SemesterName = "Học kỳ 2",
            StartDate = sem2Start,
            EndDate = sem2End
        });

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
