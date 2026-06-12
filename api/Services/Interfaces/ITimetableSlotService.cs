using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface ITimetableSlotService
{
    Task<IEnumerable<TimetableSlotDto>> GetAllAsync();
    Task<TimetableSlotDto?> GetByIdAsync(int id);
    Task<TimetableSlotDto> CreateAsync(CreateTimetableSlotDto dto);
    Task<TimetableSlotDto?> UpdateAsync(int id, UpdateTimetableSlotDto dto);
    Task<bool> DeleteAsync(int id);
}
