using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class TimetableSlotRepository(Prm393dbContext db) : ITimetableSlotRepository
{
    public async Task<IEnumerable<TimetableSlot>> GetAllAsync() =>
        await db.TimetableSlots.ToListAsync();

    public async Task<TimetableSlot?> GetByIdAsync(int id) =>
        await db.TimetableSlots.FindAsync(id);

    public async Task<TimetableSlot> CreateAsync(TimetableSlot slot)
    {
        db.TimetableSlots.Add(slot);
        await db.SaveChangesAsync();
        return slot;
    }

    public async Task<TimetableSlot?> UpdateAsync(int id, TimetableSlot updated)
    {
        var slot = await db.TimetableSlots.FindAsync(id);
        if (slot is null) return null;

        slot.SlotName = updated.SlotName;
        slot.StartTime = updated.StartTime;
        slot.EndTime = updated.EndTime;
        await db.SaveChangesAsync();
        return slot;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var slot = await db.TimetableSlots.FindAsync(id);
        if (slot is null) return false;

        db.TimetableSlots.Remove(slot);
        await db.SaveChangesAsync();
        return true;
    }
}
