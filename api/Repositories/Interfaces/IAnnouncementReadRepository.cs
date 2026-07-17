using PRM393API.Models;

namespace PRM393API.Repositories.Interfaces;

public interface IAnnouncementReadRepository
{
    Task<HashSet<int>> GetReadAnnouncementIdsAsync(int userId, IEnumerable<int> announcementIds);
    Task<bool> MarkReadAsync(int userId, int announcementId);
    Task<int> MarkAllReadAsync(int userId, IEnumerable<int> announcementIds);
}
