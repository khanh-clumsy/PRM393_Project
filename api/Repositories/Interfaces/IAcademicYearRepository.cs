using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IAcademicYearRepository
{
    Task<IEnumerable<AcademicYear>> GetAllAsync();
    Task<AcademicYear?> GetByIdAsync(int id);
    Task<AcademicYear> CreateAsync(AcademicYear year);
    Task<AcademicYear?> UpdateAsync(int id, AcademicYear year);
    Task<bool> DeleteAsync(int id);
}
