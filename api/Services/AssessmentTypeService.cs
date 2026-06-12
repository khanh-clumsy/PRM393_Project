using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class AssessmentTypeService(IAssessmentTypeRepository repo) : IAssessmentTypeService
{
    public async Task<IEnumerable<AssessmentTypeDto>> GetAllAsync() =>
        (await repo.GetAllAsync()).Select(ToDto);

    public async Task<AssessmentTypeDto?> GetByIdAsync(int id)
    {
        var t = await repo.GetByIdAsync(id);
        return t is null ? null : ToDto(t);
    }

    public async Task<AssessmentTypeDto> CreateAsync(CreateAssessmentTypeDto dto)
    {
        var entity = new AssessmentType { TypeName = dto.TypeName, Weight = dto.Weight };
        return ToDto(await repo.CreateAsync(entity));
    }

    public async Task<AssessmentTypeDto?> UpdateAsync(int id, UpdateAssessmentTypeDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.TypeName = dto.TypeName ?? existing.TypeName;
        existing.Weight = dto.Weight ?? existing.Weight;
        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) => await repo.DeleteAsync(id);

    private static AssessmentTypeDto ToDto(AssessmentType t) =>
        new(t.AssessmentTypeId, t.TypeName, t.Weight);
}
