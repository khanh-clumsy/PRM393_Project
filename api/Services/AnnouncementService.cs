using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class AnnouncementService(
    IAnnouncementRepository repo,
    IStudentClassRepository studentClassRepo,
    IParentStudentRepository parentStudentRepo,
    ITeachingAssignmentRepository teachingAssignmentRepo,
    INotificationLogRepository notificationLogRepo) : IAnnouncementService
{
    public async Task<IEnumerable<AnnouncementDto>> GetAllAsync() =>
        (await repo.GetAllAsync()).Select(ToDto);

    public async Task<AnnouncementDto?> GetByIdAsync(int id)
    {
        var a = await repo.GetByIdAsync(id);
        return a is null ? null : ToDto(a);
    }

    public async Task<IEnumerable<AnnouncementDto>> GetByClassAsync(int classId) =>
        (await repo.GetByClassAsync(classId)).Select(ToDto);

    public async Task<IEnumerable<AnnouncementDto>> GetMyFeedAsync(int userId, string role)
    {
        var normalizedRole = role.Trim();
        if (normalizedRole.Equals("Admin", StringComparison.OrdinalIgnoreCase))
        {
            return (await repo.GetFeedByClassIdsAsync([], true)).Select(ToDto);
        }

        var classIds = await GetScopedClassIdsAsync(userId, normalizedRole);
        return (await repo.GetFeedByClassIdsAsync(classIds, false)).Select(ToDto);
    }

    public async Task<AnnouncementDto> CreateAsync(CreateAnnouncementDto dto)
    {
        var now = DateTime.UtcNow;
        var entity = new Announcement
        {
            AuthorId = dto.AuthorId,
            Title = dto.Title,
            Content = dto.Content,
            AnnouncementType = dto.AnnouncementType,
            Priority = dto.Priority,
            IsDeleted = false,
            CreatedAt = now,
            UpdatedAt = now,
        };
        var created = await repo.CreateAsync(entity, dto.TargetClassIds);
        await FanOutNotificationLogsAsync(created, dto.TargetClassIds);
        return ToDto(created);
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

    private async Task FanOutNotificationLogsAsync(Announcement announcement, IEnumerable<int?> targetClassIds)
    {
        var concreteClassIds = targetClassIds.Where(id => id.HasValue).Select(id => id!.Value).Distinct().ToList();
        if (concreteClassIds.Count == 0) return;

        var recipientIds = new HashSet<int>();
        foreach (var classId in concreteClassIds)
        {
            foreach (var studentClass in await studentClassRepo.GetByClassAsync(classId))
            {
                recipientIds.Add(studentClass.StudentId);
                foreach (var parentStudent in await parentStudentRepo.GetByStudentAsync(studentClass.StudentId))
                {
                    recipientIds.Add(parentStudent.ParentId);
                }
            }
        }

        var now = DateTime.UtcNow;
        var logs = recipientIds.Select(userId => new NotificationLog
        {
            UserId = userId,
            AnnouncementId = announcement.AnnouncementId,
            Title = announcement.Title,
            Body = announcement.Content.Length <= 500 ? announcement.Content : announcement.Content[..500],
            IsRead = false,
            CreatedAt = now,
        });
        await notificationLogRepo.CreateManyAsync(logs);
    }

    private static AnnouncementDto ToDto(Announcement a) =>
        new(a.AnnouncementId, a.AuthorId, a.Title, a.Content, a.AnnouncementType, a.Priority, a.CreatedAt,
            a.AnnouncementTargets?.Select(t => t.ClassId).ToList() ?? []);
}
