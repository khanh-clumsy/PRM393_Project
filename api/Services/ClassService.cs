using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class ClassService(IClassRepository repo) : IClassService
{
    public async Task<IEnumerable<ClassDto>> GetAllAsync()
    {
        var list = await repo.GetAllAsync();
        return list.Select(ToDto);
    }

    public async Task<IEnumerable<ClassDto>> GetByAcademicYearAsync(int academicYearId)
    {
        var list = await repo.GetByAcademicYearAsync(academicYearId);
        return list.Select(ToDto);
    }

    public async Task<ClassDto?> GetByIdAsync(int id)
    {
        var cls = await repo.GetByIdAsync(id);
        return cls is null ? null : ToDto(cls);
    }

    public async Task<ClassDto> CreateAsync(CreateClassDto dto)
    {
        var cls = new Class
        {
            ClassName = dto.ClassName,
            AcademicYearId = dto.AcademicYearId,
            HomeroomTeacherId = dto.HomeroomTeacherId,
        };
        var created = await repo.CreateAsync(cls);
        return ToDto(created);
    }

    public async Task<ClassDto?> UpdateAsync(int id, UpdateClassDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.ClassName = dto.ClassName ?? existing.ClassName;
        existing.HomeroomTeacherId = dto.HomeroomTeacherId ?? existing.HomeroomTeacherId;

        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) =>
        await repo.DeleteAsync(id);

    private static ClassDto ToDto(Class c) =>
        new(c.ClassId, c.ClassName, c.AcademicYearId, c.HomeroomTeacherId);
}
