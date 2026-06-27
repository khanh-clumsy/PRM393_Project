using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class ParentStudentService(IParentStudentRepository repo) : IParentStudentService
{
    public async Task<IEnumerable<ParentStudentDto>> GetByParentAsync(int parentId)
    {
        var list = await repo.GetByParentAsync(parentId);
        return list.Select(ToDto);
    }

    public async Task<IEnumerable<ParentStudentDto>> GetByStudentAsync(int studentId)
    {
        var list = await repo.GetByStudentAsync(studentId);
        return list.Select(ToDto);
    }

    public async Task<ParentStudentDto?> GetByIdAsync(int id)
    {
        var ps = await repo.GetByIdAsync(id);
        return ps is null ? null : ToDto(ps);
    }

    public async Task<ParentStudentDto> CreateAsync(CreateParentStudentDto dto)
    {
        var ps = new ParentStudent
        {
            ParentId = dto.ParentId,
            StudentId = dto.StudentId,
            Relationship = dto.Relationship,
        };
        return ToDto(await repo.CreateAsync(ps));
    }

    public async Task<ParentStudentDto?> UpdateAsync(int id, UpdateParentStudentDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.Relationship = dto.Relationship ?? existing.Relationship;

        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) =>
        await repo.DeleteAsync(id);

    private static ParentStudentDto ToDto(ParentStudent ps) =>
        new(ps.ParentStudentId, ps.ParentId, ps.StudentId, ps.Relationship, ps.Student?.FullName, ps.Parent?.FullName, ps.Student?.Username, ps.Parent?.Username);
}
