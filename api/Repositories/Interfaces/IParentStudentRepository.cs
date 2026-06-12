using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IParentStudentRepository
{
    Task<IEnumerable<ParentStudent>> GetByParentAsync(int parentId);
    Task<IEnumerable<ParentStudent>> GetByStudentAsync(int studentId);
    Task<ParentStudent?> GetByIdAsync(int id);
    Task<ParentStudent> CreateAsync(ParentStudent ps);
    Task<ParentStudent?> UpdateAsync(int id, ParentStudent ps);
    Task<bool> DeleteAsync(int id);
}
