using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class SubjectService(ISubjectRepository repo) : ISubjectService
{
    public async Task<IEnumerable<SubjectDto>> GetAllAsync()
    {
        var list = await repo.GetAllAsync();
        return list.Select(ToDto);
    }

    public async Task<SubjectDto?> GetByIdAsync(int id)
    {
        var s = await repo.GetByIdAsync(id);
        return s is null ? null : ToDto(s);
    }

    public async Task<SubjectDto> CreateAsync(CreateSubjectDto dto)
    {
        var subject = new Subject
        {
            SubjectCode = dto.SubjectCode,
            SubjectName = dto.SubjectName,
            IsActive = dto.IsActive,
        };
        var created = await repo.CreateAsync(subject);
        return ToDto(created);
    }

    public async Task<SubjectDto?> UpdateAsync(int id, UpdateSubjectDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.SubjectCode = dto.SubjectCode ?? existing.SubjectCode;
        existing.SubjectName = dto.SubjectName ?? existing.SubjectName;
        existing.IsActive = dto.IsActive ?? existing.IsActive;

        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) =>
        await repo.DeleteAsync(id);

    private static SubjectDto ToDto(Subject s) =>
        new(s.SubjectId, s.SubjectCode, s.SubjectName, s.IsActive);
}
