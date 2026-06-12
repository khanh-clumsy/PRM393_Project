using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface ISemesterRepository
{
    Task<IEnumerable<Semester>> GetAllAsync();
    Task<IEnumerable<Semester>> GetByAcademicYearAsync(int academicYearId);
    Task<Semester?> GetByIdAsync(int id);
    Task<Semester> CreateAsync(Semester semester);
    Task<Semester?> UpdateAsync(int id, Semester semester);
    Task<bool> DeleteAsync(int id);
}
