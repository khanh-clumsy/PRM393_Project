using PRM393API.DTOs;
using PRM393API.Models;

namespace PRM393API.Services.Interfaces;

public interface IAcademicContextService
{
    Task<AcademicYear?> ResolveAcademicYearAsync(DateOnly date);
    Task<Semester?> ResolveSemesterAsync(DateOnly date);
    Task<AcademicContextAtDateDto> GetContextAtDateAsync(DateOnly date);
    Task<StudentEnrollmentAtDateDto> GetStudentEnrollmentAtDateAsync(int studentId, DateOnly date);
    Task<StudentEnrollmentDto?> ResolveStudentEnrollmentAsync(int studentId, DateOnly date);
}
