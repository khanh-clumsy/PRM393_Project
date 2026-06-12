using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IAcademicRankRepository
{
    Task<IEnumerable<AcademicRank>> GetAllAsync();
    Task<AcademicRank?> GetByIdAsync(int id);
    Task<AcademicRank> CreateAsync(AcademicRank rank);
    Task<AcademicRank?> UpdateAsync(int id, AcademicRank rank);
    Task<bool> DeleteAsync(int id);
}
