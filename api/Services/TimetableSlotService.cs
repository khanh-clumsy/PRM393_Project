using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class TimetableSlotService(ITimetableSlotRepository repo) : ITimetableSlotService
{
    public async Task<IEnumerable<TimetableSlotDto>> GetAllAsync()
    {
        var list = await repo.GetAllAsync();
        return list.Select(ToDto);
    }

    public async Task<TimetableSlotDto?> GetByIdAsync(int id)
    {
        var slot = await repo.GetByIdAsync(id);
        return slot is null ? null : ToDto(slot);
    }

    public async Task<TimetableSlotDto> CreateAsync(CreateTimetableSlotDto dto)
    {
        var slot = new TimetableSlot
        {
            SlotName = dto.SlotName,
            StartTime = dto.StartTime,
            EndTime = dto.EndTime,
        };
        return ToDto(await repo.CreateAsync(slot));
    }

    public async Task<TimetableSlotDto?> UpdateAsync(int id, UpdateTimetableSlotDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.SlotName = dto.SlotName ?? existing.SlotName;
        existing.StartTime = dto.StartTime ?? existing.StartTime;
        existing.EndTime = dto.EndTime ?? existing.EndTime;

        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) =>
        await repo.DeleteAsync(id);

    private static TimetableSlotDto ToDto(TimetableSlot s) =>
        new(s.SlotId, s.SlotName, s.StartTime, s.EndTime);
}
