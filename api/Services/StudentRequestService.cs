using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class StudentRequestService(
    IStudentRequestRepository repo,
    IParentStudentRepository parentStudentRepo,
    ITeachingAssignmentRepository teachingAssignmentRepo,
    IClassRepository classRepo) : IStudentRequestService
{
    public async Task<StudentRequestDto?> GetByIdAsync(int id)
    {
        var r = await repo.GetByIdAsync(id);
        return r is null ? null : ToDto(r);
    }

    public async Task<IEnumerable<StudentRequestDto>> GetByStudentAsync(int studentId) =>
        (await repo.GetByStudentAsync(studentId)).Select(ToDto);

    public async Task<IEnumerable<StudentRequestDto>> GetPendingAsync() =>
        (await repo.GetPendingAsync()).Select(ToDto);

    public async Task<IEnumerable<StudentRequestDto>> GetPendingForTeacherAsync(int teacherId)
    {
        // GV dạy lớp (TeachingAssignments) ∪ GVCN (HomeroomTeacherId)
        var taught = (await teachingAssignmentRepo.GetByTeacherAsync(teacherId)).Select(ta => ta.ClassId);
        var homeroom = (await classRepo.GetByHomeroomTeacherAsync(teacherId)).Select(c => c.ClassId);
        var classIds = taught.Concat(homeroom).Distinct().ToList();
        return (await repo.GetPendingByClassIdsAsync(classIds)).Select(ToDto);
    }

    public async Task<StudentRequestDto> CreateAsync(CreateStudentRequestDto dto)
    {
        var entity = new StudentRequest
        {
            StudentId = dto.StudentId,
            RequestedBy = dto.RequestedBy,
            LeaveDate = dto.LeaveDate,
            Reason = dto.Reason,
            AttachmentUrl = dto.AttachmentUrl,
            Status = "Pending",
            CreatedAt = DateTime.UtcNow,
        };
        return ToDto(await repo.CreateAsync(entity));
    }

    public async Task<StudentRequestDto> CreateForCurrentUserAsync(CreateStudentRequestDto dto, int currentUserId, string role)
    {
        if (role.Equals("Student", StringComparison.OrdinalIgnoreCase) && dto.StudentId != currentUserId)
        {
            throw new UnauthorizedAccessException("Student can only create leave requests for self.");
        }

        if (role.Equals("Parent", StringComparison.OrdinalIgnoreCase))
        {
            var children = await parentStudentRepo.GetByParentAsync(currentUserId);
            if (!children.Any(ps => ps.StudentId == dto.StudentId))
            {
                throw new UnauthorizedAccessException("Parent is not linked to this student.");
            }
        }

        return await CreateAsync(dto with { RequestedBy = currentUserId });
    }

    public async Task<StudentRequestDto?> ReviewAsync(int id, ReviewStudentRequestDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;
        if (!dto.Status.Equals("Approved", StringComparison.OrdinalIgnoreCase) &&
            !dto.Status.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
        {
            throw new ArgumentException("Status must be Approved or Rejected.", nameof(dto));
        }

        if (!existing.Status.Equals("Pending", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Only pending requests can be reviewed.");
        }

        existing.Status = dto.Status;
        existing.ReviewedBy = dto.ReviewedBy;
        existing.ReviewNote = dto.ReviewNote;
        existing.ReviewedAt = DateTime.UtcNow;
        var updated = await repo.ReviewAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<StudentRequestDto?> ReviewForTeacherAsync(int id, ReviewStudentRequestDto dto, int teacherId)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        var classIds = await GetTeacherClassIdsAsync(teacherId);
        if (!await repo.StudentHasClassAsync(existing.StudentId, classIds))
        {
            throw new UnauthorizedAccessException("Teacher can only review leave requests for assigned or homeroom classes.");
        }

        return await ReviewAsync(id, dto with { ReviewedBy = teacherId });
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return false;
        if (!existing.Status.Equals("Pending", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Chỉ hủy được đơn đang chờ duyệt.");
        return await repo.DeleteAsync(id);
    }

    private static StudentRequestDto ToDto(StudentRequest r) =>
        new(r.StudentRequestId, r.StudentId, r.Student?.FullName, r.RequestedBy, r.RequestedByNavigation?.FullName,
            r.LeaveDate, r.Reason, r.AttachmentUrl, r.Status, r.ReviewedBy, r.ReviewedAt, r.ReviewNote, r.CreatedAt);

    private async Task<List<int>> GetTeacherClassIdsAsync(int teacherId)
    {
        var taught = (await teachingAssignmentRepo.GetByTeacherAsync(teacherId)).Select(ta => ta.ClassId);
        var homeroom = (await classRepo.GetByHomeroomTeacherAsync(teacherId)).Select(c => c.ClassId);
        return taught.Concat(homeroom).Distinct().ToList();
    }
}
