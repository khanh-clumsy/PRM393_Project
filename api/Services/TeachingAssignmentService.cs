using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class TeachingAssignmentService(ITeachingAssignmentRepository repo) : ITeachingAssignmentService
{
    public async Task<IEnumerable<TeachingAssignmentDto>> GetAllAsync()
    {
        var list = await repo.GetAllAsync();
        return list.Select(ToDto);
    }

    public async Task<IEnumerable<TeachingAssignmentDto>> GetByTeacherAsync(int teacherId)
    {
        var list = await repo.GetByTeacherAsync(teacherId);
        return list.Select(ToDto);
    }

    public async Task<IEnumerable<TeachingAssignmentDto>> GetByClassAsync(int classId)
    {
        var list = await repo.GetByClassAsync(classId);
        return list.Select(ToDto);
    }

    public async Task<IEnumerable<TeachingAssignmentDto>> GetBySemesterAsync(int semesterId)
    {
        var list = await repo.GetBySemesterAsync(semesterId);
        return list.Select(ToDto);
    }

    public async Task<TeachingAssignmentDto?> GetByIdAsync(int id)
    {
        var ta = await repo.GetByIdAsync(id);
        return ta is null ? null : ToDto(ta);
    }

    public async Task<TeachingAssignmentDto> CreateAsync(CreateTeachingAssignmentDto dto)
    {
        var existing = await repo.GetByClassAsync(dto.ClassId);
        if (existing.Any(taInfo => taInfo.TeacherId == dto.TeacherId && taInfo.SubjectId == dto.SubjectId && taInfo.SemesterId == dto.SemesterId))
        {
            throw new InvalidOperationException("Giáo viên này đã được phân công dạy môn học này tại lớp trong học kỳ.");
        }

        var ta = new TeachingAssignment
        {
            TeacherId = dto.TeacherId,
            ClassId = dto.ClassId,
            SubjectId = dto.SubjectId,
            SemesterId = dto.SemesterId,
        };
        return ToDto(await repo.CreateAsync(ta));
    }

    public async Task<TeachingAssignmentDto?> UpdateAsync(int id, UpdateTeachingAssignmentDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        var classAssignments = await repo.GetByClassAsync(dto.ClassId);
        if (classAssignments.Any(ta =>
                ta.TeachingAssignmentId != id &&
                ta.TeacherId == dto.TeacherId &&
                ta.SubjectId == dto.SubjectId &&
                ta.SemesterId == dto.SemesterId))
        {
            throw new InvalidOperationException("Giáo viên này đã được phân công dạy môn học này tại lớp trong học kỳ.");
        }

        existing.TeacherId = dto.TeacherId;
        existing.ClassId = dto.ClassId;
        existing.SubjectId = dto.SubjectId;
        existing.SemesterId = dto.SemesterId;

        var updated = await repo.UpdateAsync(existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) =>
        await repo.DeleteAsync(id);

    private static TeachingAssignmentDto ToDto(TeachingAssignment ta) =>
        new(ta.TeachingAssignmentId, ta.TeacherId, ta.ClassId, ta.SubjectId, ta.SemesterId, ta.Class?.ClassName, ta.Subject?.SubjectName);
}
