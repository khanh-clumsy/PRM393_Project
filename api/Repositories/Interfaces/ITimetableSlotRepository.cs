using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface ITimetableSlotRepository
{
    Task<IEnumerable<TimetableSlot>> GetAllAsync();
    Task<TimetableSlot?> GetByIdAsync(int id);
    Task<TimetableSlot> CreateAsync(TimetableSlot slot);
    Task<TimetableSlot?> UpdateAsync(int id, TimetableSlot slot);
    Task<bool> DeleteAsync(int id);
}
