using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class AssessmentService(IAssessmentRepository repo) : IAssessmentService
{
    public async Task<IEnumerable<AssessmentDto>> GetAllAsync() =>
        (await repo.GetAllAsync()).Select(ToDto);

    public async Task<AssessmentDto?> GetByIdAsync(int id)
    {
        var a = await repo.GetByIdAsync(id);
        return a is null ? null : ToDto(a);
    }

    public async Task<IEnumerable<AssessmentDto>> GetByTeachingAssignmentAsync(int teachingAssignmentId) =>
        (await repo.GetByTeachingAssignmentAsync(teachingAssignmentId)).Select(ToDto);

    public async Task<AssessmentDto> CreateAsync(CreateAssessmentDto dto)
    {
        var entity = new Assessment
        {
            TeachingAssignmentId = dto.TeachingAssignmentId,
            AssessmentTypeId = dto.AssessmentTypeId,
            AssessmentName = dto.AssessmentName,
            AssessmentDate = dto.AssessmentDate,
            MaxScore = dto.MaxScore,
        };
        return ToDto(await repo.CreateAsync(entity));
    }

    public async Task<AssessmentDto?> UpdateAsync(int id, UpdateAssessmentDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.AssessmentName = dto.AssessmentName ?? existing.AssessmentName;
        existing.AssessmentDate = dto.AssessmentDate ?? existing.AssessmentDate;
        existing.MaxScore = dto.MaxScore ?? existing.MaxScore;
        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) => await repo.DeleteAsync(id);

    private static AssessmentDto ToDto(Assessment a) =>
        new(a.AssessmentId, a.TeachingAssignmentId, a.AssessmentTypeId, a.AssessmentName, a.AssessmentDate, a.MaxScore);
}
