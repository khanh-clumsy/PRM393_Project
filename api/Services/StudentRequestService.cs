using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class StudentRequestService(IStudentRequestRepository repo) : IStudentRequestService
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

    public async Task<StudentRequestDto?> ReviewAsync(int id, ReviewStudentRequestDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.Status = dto.Status;
        existing.ReviewedBy = dto.ReviewedBy;
        existing.ReviewNote = dto.ReviewNote;
        existing.ReviewedAt = DateTime.UtcNow;
        var updated = await repo.ReviewAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) => await repo.DeleteAsync(id);

    private static StudentRequestDto ToDto(StudentRequest r) =>
        new(r.StudentRequestId, r.StudentId, r.RequestedBy, r.LeaveDate, r.Reason, r.AttachmentUrl, r.Status, r.ReviewedBy, r.ReviewedAt, r.ReviewNote, r.CreatedAt);
}
