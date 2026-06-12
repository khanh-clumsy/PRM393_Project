using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class AssignmentService(IAssignmentRepository repo) : IAssignmentService
{
    public async Task<IEnumerable<AssignmentDto>> GetAllAsync() =>
        (await repo.GetAllAsync()).Select(ToDto);

    public async Task<AssignmentDto?> GetByIdAsync(int id)
    {
        var a = await repo.GetByIdAsync(id);
        return a is null ? null : ToDto(a);
    }

    public async Task<IEnumerable<AssignmentDto>> GetByTeachingAssignmentAsync(int teachingAssignmentId) =>
        (await repo.GetByTeachingAssignmentAsync(teachingAssignmentId)).Select(ToDto);

    public async Task<AssignmentDto> CreateAsync(CreateAssignmentDto dto)
    {
        var now = DateTime.UtcNow;
        var entity = new Assignment
        {
            TeachingAssignmentId = dto.TeachingAssignmentId,
            Title = dto.Title,
            Description = dto.Description,
            AttachmentUrl = dto.AttachmentUrl,
            DueDate = dto.DueDate,
            CreatedBy = dto.CreatedBy,
            CreatedAt = now,
            UpdatedAt = now,
            IsDeleted = false,
        };
        return ToDto(await repo.CreateAsync(entity));
    }

    public async Task<AssignmentDto?> UpdateAsync(int id, UpdateAssignmentDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.Title = dto.Title ?? existing.Title;
        existing.Description = dto.Description ?? existing.Description;
        existing.AttachmentUrl = dto.AttachmentUrl ?? existing.AttachmentUrl;
        existing.DueDate = dto.DueDate ?? existing.DueDate;
        existing.UpdatedAt = DateTime.UtcNow;
        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) => await repo.SoftDeleteAsync(id);

    private static AssignmentDto ToDto(Assignment a) =>
        new(a.AssignmentId, a.TeachingAssignmentId, a.Title, a.Description, a.AttachmentUrl, a.DueDate, a.CreatedBy, a.CreatedAt);
}
