using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class StudentYearlySummaryService(IStudentYearlySummaryRepository repo) : IStudentYearlySummaryService
{
    public async Task<StudentYearlySummaryDto?> GetByIdAsync(int id)
    {
        var s = await repo.GetByIdAsync(id);
        return s is null ? null : ToDto(s);
    }

    public async Task<IEnumerable<StudentYearlySummaryDto>> GetByStudentAsync(int studentId) =>
        (await repo.GetByStudentAsync(studentId)).Select(ToDto);

    public async Task<IEnumerable<StudentYearlySummaryDto>> GetByYearAsync(int academicYearId) =>
        (await repo.GetByYearAsync(academicYearId)).Select(ToDto);

    public async Task<StudentYearlySummaryDto> CreateAsync(CreateYearlySummaryDto dto)
    {
        var entity = new StudentYearlySummary
        {
            StudentId = dto.StudentId,
            AcademicYearId = dto.AcademicYearId,
            YearlyGpa = dto.YearlyGpa,
            YearlyConduct = dto.YearlyConduct,
            RankId = dto.RankId,
            EvaluatedBy = dto.EvaluatedBy,
            EvaluatedAt = DateTime.UtcNow,
        };
        return ToDto(await repo.CreateAsync(entity));
    }

    public async Task<StudentYearlySummaryDto?> UpdateAsync(int id, UpdateYearlySummaryDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.YearlyGpa = dto.YearlyGpa ?? existing.YearlyGpa;
        existing.YearlyConduct = dto.YearlyConduct ?? existing.YearlyConduct;
        existing.RankId = dto.RankId ?? existing.RankId;
        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) => await repo.DeleteAsync(id);

    private static StudentYearlySummaryDto ToDto(StudentYearlySummary s) =>
        new(s.YearlySummaryId, s.StudentId, s.AcademicYearId, s.YearlyGpa, s.YearlyConduct, s.RankId, s.EvaluatedBy, s.EvaluatedAt);
}
