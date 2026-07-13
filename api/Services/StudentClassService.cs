using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class StudentClassService(
    IStudentClassRepository repo,
    IClassRepository classRepo,
    IAcademicContextService academicContext) : IStudentClassService
{
    public async Task<IEnumerable<StudentClassResponseDto>> GetByClassAsync(int classId)
    {
        var list = await repo.GetByClassAsync(classId);
        return list.Select(ToDto);
    }

    public async Task<IEnumerable<StudentClassResponseDto>> GetByStudentAsync(int studentId)
    {
        var list = await repo.GetByStudentAsync(studentId);
        return list.Select(ToDto);
    }

    public Task<StudentEnrollmentAtDateDto> GetEnrollmentAtDateAsync(int studentId, DateOnly date) =>
        academicContext.GetStudentEnrollmentAtDateAsync(studentId, date);

    public async Task<StudentClassResponseDto> CreateAsync(CreateStudentClassDto dto)
    {
        // 1. Get the target class to know its AcademicYearId
        var targetClass = await classRepo.GetByIdAsync(dto.ClassId) 
            ?? throw new KeyNotFoundException("Lớp học không tồn tại");

        // 2. Check if student already has a class in the same year
        var studentClasses = await repo.GetByStudentAsync(dto.StudentId);
        foreach (var scInfo in studentClasses)
        {
            var c = await classRepo.GetByIdAsync(scInfo.ClassId);
            if (c != null && c.AcademicYearId == targetClass.AcademicYearId)
            {
                throw new InvalidOperationException("Học sinh này đã được phân vào một lớp khác trong cùng năm học.");
            }
        }

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

    private static StudentClassResponseDto ToDto(StudentClass sc) =>
        new(sc.StudentClassId, sc.StudentId, sc.ClassId, sc.Student?.FullName, sc.Student?.Username);
}
