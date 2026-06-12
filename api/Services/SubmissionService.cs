using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class SubmissionService(ISubmissionRepository repo) : ISubmissionService
{
    public async Task<SubmissionDto?> GetByIdAsync(int id)
    {
        var s = await repo.GetByIdAsync(id);
        return s is null ? null : ToDto(s);
    }

    public async Task<IEnumerable<SubmissionDto>> GetByAssignmentAsync(int assignmentId) =>
        (await repo.GetByAssignmentAsync(assignmentId)).Select(ToDto);

    public async Task<IEnumerable<SubmissionDto>> GetByStudentAsync(int studentId) =>
        (await repo.GetByStudentAsync(studentId)).Select(ToDto);

    public async Task<SubmissionDto> CreateAsync(CreateSubmissionDto dto)
    {
        var entity = new Submission
        {
            AssignmentId = dto.AssignmentId,
            StudentId = dto.StudentId,
            ContentText = dto.ContentText,
            FileUrl = dto.FileUrl,
            LinkUrl = dto.LinkUrl,
            SubmittedAt = DateTime.UtcNow,
        };
        return ToDto(await repo.CreateAsync(entity));
    }

    public async Task<SubmissionDto?> GradeAsync(int id, GradeSubmissionDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.Score = dto.Score;
        existing.Feedback = dto.Feedback;
        existing.GradedBy = dto.GradedBy;
        existing.GradedAt = DateTime.UtcNow;
        var updated = await repo.GradeAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) => await repo.DeleteAsync(id);

    private static SubmissionDto ToDto(Submission s) =>
        new(s.SubmissionId, s.AssignmentId, s.StudentId, s.ContentText, s.FileUrl, s.LinkUrl, s.SubmittedAt, s.Score, s.Feedback, s.GradedBy, s.GradedAt);
}
