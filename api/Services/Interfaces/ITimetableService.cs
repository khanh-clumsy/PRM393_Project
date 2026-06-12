using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface ITimetableService
{
    Task<IEnumerable<TimetableDto>> GetAllAsync();
    Task<IEnumerable<TimetableDto>> GetByAssignmentAsync(int teachingAssignmentId);
    Task<IEnumerable<TimetableDto>> GetByClassAsync(int classId);
    Task<TimetableDto?> GetByIdAsync(int id);
    Task<TimetableDto> CreateAsync(CreateTimetableDto dto);
    Task<TimetableDto?> UpdateAsync(int id, UpdateTimetableDto dto);
    Task<bool> DeleteAsync(int id);
}
