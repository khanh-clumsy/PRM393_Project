using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class AnnouncementService(IAnnouncementRepository repo) : IAnnouncementService
{
    public async Task<IEnumerable<AnnouncementDto>> GetAllAsync() =>
        (await repo.GetAllAsync()).Select(ToDto);

    public async Task<AnnouncementDto?> GetByIdAsync(int id)
    {
        var a = await repo.GetByIdAsync(id);
        return a is null ? null : ToDto(a);
    }

    public async Task<IEnumerable<AnnouncementDto>> GetByClassAsync(int classId) =>
        (await repo.GetByClassAsync(classId)).Select(ToDto);

    public async Task<AnnouncementDto> CreateAsync(CreateAnnouncementDto dto)
    {
        var now = DateTime.UtcNow;
        var entity = new Announcement
        {
            AuthorId = dto.AuthorId,
            Title = dto.Title,
            Content = dto.Content,
            AnnouncementType = dto.AnnouncementType,
            Priority = dto.Priority,
            IsDeleted = false,
            CreatedAt = now,
            UpdatedAt = now,
        };
        return ToDto(await repo.CreateAsync(entity, dto.TargetClassIds));
    }

    public async Task<AnnouncementDto?> UpdateAsync(int id, UpdateAnnouncementDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.Title = dto.Title ?? existing.Title;
        existing.Content = dto.Content ?? existing.Content;
        existing.Priority = dto.Priority ?? existing.Priority;
        existing.UpdatedAt = DateTime.UtcNow;
        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) => await repo.SoftDeleteAsync(id);

    private static AnnouncementDto ToDto(Announcement a) =>
        new(a.AnnouncementId, a.AuthorId, a.Title, a.Content, a.AnnouncementType, a.Priority, a.CreatedAt,
            a.AnnouncementTargets?.Select(t => t.ClassId).ToList() ?? []);
}
