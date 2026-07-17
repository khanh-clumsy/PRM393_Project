using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class AnnouncementService(
    IAnnouncementRepository repo,
    IAnnouncementReadRepository readRepo,
    IStudentClassRepository studentClassRepo,
    IParentStudentRepository parentStudentRepo,
    ITeachingAssignmentRepository teachingAssignmentRepo) : IAnnouncementService
{
    public async Task<IEnumerable<AnnouncementDto>> GetAllAsync() =>
        (await repo.GetAllAsync()).Select(a => ToDto(a));

    public async Task<AnnouncementDto?> GetByIdAsync(int id)
    {
        var a = await repo.GetByIdAsync(id);
        return a is null ? null : ToDto(a);
    }

    public async Task<IEnumerable<AnnouncementDto>> GetByClassAsync(int classId) =>
        (await repo.GetByClassAsync(classId)).Select(a => ToDto(a));

    public async Task<IEnumerable<AnnouncementDto>> GetMyFeedAsync(int userId, string role)
    {
        var normalizedRole = role.Trim();
        IEnumerable<Announcement> feed;
        if (normalizedRole.Equals("Admin", StringComparison.OrdinalIgnoreCase))
        {
            feed = await repo.GetFeedByClassIdsAsync([], true);
        }
        else
        {
            var classIds = await GetScopedClassIdsAsync(userId, normalizedRole);
            feed = await repo.GetFeedByClassIdsAsync(classIds, false);
        }

        var list = feed.ToList();
        var readIds = await readRepo.GetReadAnnouncementIdsAsync(userId, list.Select(a => a.AnnouncementId));
        return list.Select(a => ToDto(a, readIds.Contains(a.AnnouncementId)));
    }

    public async Task<bool> MarkReadAsync(int userId, int announcementId) =>
        await readRepo.MarkReadAsync(userId, announcementId);

    public async Task<int> MarkAllReadAsync(int userId, string role)
    {
        var feed = await GetMyFeedAsync(userId, role);
        var ids = feed.Select(a => a.AnnouncementId);
        return await readRepo.MarkAllReadAsync(userId, ids);
    }

    public async Task<AnnouncementDto> CreateAsync(CreateAnnouncementDto dto)
    {
        var now = DateTime.UtcNow;
        var type = NormalizeType(dto.AnnouncementType);
        var priority = NormalizePriority(dto.Priority);
        var targetClassIds = NormalizeTargets(type, dto.TargetClassIds);

        var entity = new Announcement
        {
            AuthorId = dto.AuthorId,
            Title = dto.Title,
            Content = dto.Content,
            AnnouncementType = type,
            Priority = priority,
            IsDeleted = false,
            CreatedAt = now,
            UpdatedAt = now,
        };
        var created = await repo.CreateAsync(entity, targetClassIds);
        return ToDto(created);
    }

    private static string NormalizeType(string type) =>
        type.Trim().ToLowerInvariant() switch
        {
            "global" or "school" => "global",
            "class" => "class",
            "internal" => "internal",
            _ => throw new ArgumentException($"Loại thông báo không hợp lệ: {type}")
        };

    private static string NormalizePriority(string priority) =>
        priority.Trim().ToLowerInvariant() switch
        {
            "normal" => "normal",
            "high" => "high",
            "urgent" => "urgent",
            _ => throw new ArgumentException($"Mức ưu tiên không hợp lệ: {priority}")
        };

    /// <summary>
    /// Global không chọn lớp → vẫn phải có 1 target ClassId=null để my-feed nhận được.
    /// Class bắt buộc có ít nhất 1 lớp.
    /// </summary>
    private static List<int?> NormalizeTargets(string type, List<int?> targetClassIds)
    {
        var cleaned = (targetClassIds ?? [])
            .Where(id => id is null || id > 0)
            .Distinct()
            .ToList();

        if (type == "global")
        {
            return cleaned.Count == 0 ? [null] : cleaned;
        }

        if (type == "class" && cleaned.All(id => id is null))
            throw new ArgumentException("Thông báo lớp phải chọn ít nhất 1 lớp.");

        return cleaned;
    }

    public async Task<AnnouncementDto?> UpdateAsync(int id, UpdateAnnouncementDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.Title = dto.Title ?? existing.Title;
        existing.Content = dto.Content ?? existing.Content;
        existing.Priority = dto.Priority ?? existing.Priority;
        existing.UpdatedAt = DateTime.UtcNow;
        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) => await repo.SoftDeleteAsync(id);

    private async Task<List<int>> GetScopedClassIdsAsync(int userId, string role)
    {
        if (role.Equals("Student", StringComparison.OrdinalIgnoreCase))
        {
            return (await studentClassRepo.GetByStudentAsync(userId)).Select(sc => sc.ClassId).Distinct().ToList();
        }

        if (role.Equals("Parent", StringComparison.OrdinalIgnoreCase))
        {
            var children = (await parentStudentRepo.GetByParentAsync(userId)).Select(ps => ps.StudentId).Distinct().ToList();
            var classIds = new List<int>();
            foreach (var studentId in children)
            {
                classIds.AddRange((await studentClassRepo.GetByStudentAsync(studentId)).Select(sc => sc.ClassId));
            }

            return classIds.Distinct().ToList();
        }

        if (role.Equals("Teacher", StringComparison.OrdinalIgnoreCase))
        {
            return (await teachingAssignmentRepo.GetByTeacherAsync(userId)).Select(ta => ta.ClassId).Distinct().ToList();
        }

        return [];
    }

    private static AnnouncementDto ToDto(Announcement a, bool isRead = false) =>
        new(a.AnnouncementId, a.AuthorId, a.Title, a.Content, a.AnnouncementType, a.Priority, a.CreatedAt,
            a.AnnouncementTargets?.Select(t => t.ClassId).ToList() ?? [], isRead);
}
