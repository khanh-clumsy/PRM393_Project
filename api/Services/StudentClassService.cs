using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class StudentClassService(IStudentClassRepository repo) : IStudentClassService
{
    public async Task<IEnumerable<StudentClassDto>> GetByClassAsync(int classId)
    {
        var list = await repo.GetByClassAsync(classId);
        return list.Select(ToDto);
    }

    public async Task<IEnumerable<StudentClassDto>> GetByStudentAsync(int studentId)
    {
        var list = await repo.GetByStudentAsync(studentId);
        return list.Select(ToDto);
    }

    public async Task<StudentClassDto> CreateAsync(CreateStudentClassDto dto)
    {
        var sc = new StudentClass
        {
            StudentId = dto.StudentId,
            ClassId = dto.ClassId,
        };
        var created = await repo.CreateAsync(sc);
        return ToDto(created);
    }

    public async Task<bool> DeleteAsync(int id) =>
        await repo.DeleteAsync(id);

    private static StudentClassDto ToDto(StudentClass sc) =>
        new(sc.StudentClassId, sc.StudentId, sc.ClassId);
}
