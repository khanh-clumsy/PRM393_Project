using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface ISubjectRepository
{
    Task<IEnumerable<Subject>> GetAllAsync();
    Task<Subject?> GetByIdAsync(int id);
    Task<Subject> CreateAsync(Subject subject);
    Task<Subject?> UpdateAsync(int id, Subject subject);
    Task<bool> DeleteAsync(int id);
}
