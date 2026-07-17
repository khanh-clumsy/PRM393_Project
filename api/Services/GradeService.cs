using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class GradeService(IGradeRepository repo, ITeachingAssignmentRepository teachingAssignmentRepo) : IGradeService
{
    public async Task<GradeDto?> GetByIdAsync(int id)
    {
        var g = await repo.GetByIdAsync(id);
        return g is null ? null : ToDto(g);
    }

    public async Task<IEnumerable<GradeDto>> GetByAssessmentAsync(int assessmentId) =>
        (await repo.GetByAssessmentAsync(assessmentId)).Select(ToDto);

    public async Task<IEnumerable<GradeDto>> GetByStudentAsync(int studentId) =>
        (await repo.GetByStudentAsync(studentId)).Select(ToDto);

    public async Task<GradeDto> CreateAsync(CreateGradeDto dto)
    {
        var entity = new Grade
        {
            AssessmentId = dto.AssessmentId,
            StudentId = dto.StudentId,
            Score = dto.Score,
            Comment = dto.Comment,
            EnteredBy = dto.EnteredBy,
            EnteredAt = DateTime.UtcNow,
        };
        return ToDto(await repo.CreateAsync(entity));
    }

    public async Task<GradeDto?> UpdateAsync(int id, UpdateGradeDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.Score = dto.Score ?? existing.Score;
        existing.Comment = dto.Comment ?? existing.Comment;
        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) => await repo.DeleteAsync(id);

    public async Task<AcademicTranscriptDto> GetStudentTranscriptAsync(int studentId, int academicYearId) =>
        await repo.GetStudentTranscriptAsync(studentId, academicYearId);

    public async Task<YearlyTranscriptDto> GetYearlyTranscriptAsync(int studentId, int academicYearId) =>
        await repo.GetYearlyTranscriptAsync(studentId, academicYearId);

    public async Task<IEnumerable<StudentGradeEntryDto>> GetClassGradesAsync(int teachingAssignmentId, int assessmentId) =>
        await repo.GetClassGradesAsync(teachingAssignmentId, assessmentId);

    public async Task SaveBulkGradesAsync(List<BulkGradeDto> grades) =>
        await repo.SaveBulkGradesAsync(grades);

    public async Task<IEnumerable<StudentGradeByTypeDto>> GetClassGradesByTypeAsync(int teachingAssignmentId, int assessmentTypeId) =>
        await repo.GetClassGradesByTypeAsync(teachingAssignmentId, assessmentTypeId);

    public async Task<IEnumerable<StudentGradeByTypeDto>> GetClassGradesByTypeForCurrentUserAsync(
        int teachingAssignmentId,
        int assessmentTypeId,
        int currentUserId,
        string role)
    {
        if (role.Equals("Teacher", StringComparison.OrdinalIgnoreCase))
        {
            await EnsureTeacherOwnsAssignmentAsync(teachingAssignmentId, currentUserId);
        }

        return await GetClassGradesByTypeAsync(teachingAssignmentId, assessmentTypeId);
    }

    public async Task SaveBulkGradesByTypeAsync(BulkGradeByTypeDto dto, int teacherId)
    {
        await EnsureTeacherOwnsAssignmentAsync(dto.TeachingAssignmentId, teacherId);

        await repo.SaveBulkGradesByTypeAsync(dto, teacherId);
    }

    private async Task EnsureTeacherOwnsAssignmentAsync(int teachingAssignmentId, int teacherId)
    {
        var assignment = await teachingAssignmentRepo.GetByIdAsync(teachingAssignmentId);
        if (assignment is null)
        {
            throw new ArgumentException("Không tìm thấy phân công giảng dạy.", nameof(teachingAssignmentId));
        }

        if (assignment.TeacherId != teacherId)
        {
            throw new UnauthorizedAccessException("Giáo viên chỉ được nhập điểm cho lớp và môn được phân công.");
        }
    }

    private static GradeDto ToDto(Grade g) =>
        new(g.GradeId, g.AssessmentId, g.StudentId, g.Score, g.Comment, g.EnteredBy, g.EnteredAt);
}
