using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IClassRepository
{
    Task<IEnumerable<Class>> GetAllAsync();
    Task<IEnumerable<Class>> GetByAcademicYearAsync(int academicYearId);
    Task<IEnumerable<Class>> GetByHomeroomTeacherAsync(int teacherId);
    Task<Class?> GetByIdAsync(int id);
    Task<Class> CreateAsync(Class cls);
    Task<Class?> UpdateAsync(int id, Class cls);
    Task<bool> DeleteAsync(int id);
}
