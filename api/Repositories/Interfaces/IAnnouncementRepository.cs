using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IAnnouncementRepository
{
    Task<IEnumerable<Announcement>> GetAllAsync();
    Task<Announcement?> GetByIdAsync(int id);
    Task<IEnumerable<Announcement>> GetByClassAsync(int classId);
    Task<IEnumerable<Announcement>> GetFeedByClassIdsAsync(IEnumerable<int> classIds, bool includeAll);
    Task<Announcement> CreateAsync(Announcement announcement, List<int?> targetClassIds);
    Task<Announcement?> UpdateAsync(int id, Announcement updated);
    Task<bool> SoftDeleteAsync(int id);
}
