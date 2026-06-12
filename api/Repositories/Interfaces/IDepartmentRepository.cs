using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IDepartmentRepository
{
    Task<IEnumerable<Department>> GetAllAsync();
    Task<Department?> GetByIdAsync(int id);
    Task<Department> CreateAsync(Department dept);
    Task<Department?> UpdateAsync(int id, Department dept);
    Task<bool> DeleteAsync(int id);
}
