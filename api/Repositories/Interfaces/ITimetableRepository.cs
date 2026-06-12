using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface ITimetableRepository
{
    Task<IEnumerable<Timetable>> GetAllAsync();
    Task<IEnumerable<Timetable>> GetByAssignmentAsync(int teachingAssignmentId);
    Task<IEnumerable<Timetable>> GetByClassAsync(int classId);
    Task<Timetable?> GetByIdAsync(int id);
    Task<Timetable?> GetDetailAsync(int id);
    Task<IEnumerable<Timetable>> GetWeeklyByClassAsync(int classId, DateOnly date);
    Task<IEnumerable<Timetable>> GetWeeklyByTeacherAsync(int teacherId, DateOnly date);
    Task<Timetable> CreateAsync(Timetable timetable);
    Task<Timetable?> UpdateAsync(int id, Timetable timetable);
    Task<bool> DeleteAsync(int id);
}
