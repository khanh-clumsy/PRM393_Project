using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class StudentSemesterSummaryService(IStudentSemesterSummaryRepository repo) : IStudentSemesterSummaryService
{
    public async Task<StudentSemesterSummaryDto?> GetByIdAsync(int id)
    {
        var s = await repo.GetByIdAsync(id);
        return s is null ? null : ToDto(s);
    }

    public async Task<IEnumerable<StudentSemesterSummaryDto>> GetByStudentAsync(int studentId) =>
        (await repo.GetByStudentAsync(studentId)).Select(ToDto);

    public async Task<IEnumerable<StudentSemesterSummaryDto>> GetBySemesterAsync(int semesterId) =>
        (await repo.GetBySemesterAsync(semesterId)).Select(ToDto);

    public async Task<StudentSemesterSummaryDto> CreateAsync(CreateSemesterSummaryDto dto)
    {
        var entity = new StudentSemesterSummary
        {
            StudentId = dto.StudentId,
            SemesterId = dto.SemesterId,
            Gpa = dto.Gpa,
            Conduct = dto.Conduct,
            RankId = dto.RankId,
            EvaluatedBy = dto.EvaluatedBy,
            EvaluatedAt = DateTime.UtcNow,
        };
        return ToDto(await repo.CreateAsync(entity));
    }

    public async Task<StudentSemesterSummaryDto?> UpdateAsync(int id, UpdateSemesterSummaryDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.Gpa = dto.Gpa ?? existing.Gpa;
        existing.Conduct = dto.Conduct ?? existing.Conduct;
        existing.RankId = dto.RankId ?? existing.RankId;
        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) => await repo.DeleteAsync(id);

    private static StudentSemesterSummaryDto ToDto(StudentSemesterSummary s) =>
        new(s.SummaryId, s.StudentId, s.SemesterId, s.Gpa, s.Conduct, s.RankId, s.EvaluatedBy, s.EvaluatedAt);
}
