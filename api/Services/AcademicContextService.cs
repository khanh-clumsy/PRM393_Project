using Microsoft.EntityFrameworkCore;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class AcademicContextService(Prm393dbContext db) : IAcademicContextService
{
    public Task<AcademicYear?> ResolveAcademicYearAsync(DateOnly date) =>
        db.AcademicYears
            .Where(y => date >= y.StartDate && date <= y.EndDate)
            .OrderByDescending(y => y.StartDate)
            .FirstOrDefaultAsync();

    public Task<Semester?> ResolveSemesterAsync(DateOnly date) =>
        db.Semesters
            .Where(s => date >= s.StartDate && date <= s.EndDate)
            .OrderByDescending(s => s.StartDate)
            .FirstOrDefaultAsync();

    public async Task<AcademicContextAtDateDto> GetContextAtDateAsync(DateOnly date)
    {
        var year = await ResolveAcademicYearAsync(date);
        var semester = await ResolveSemesterAsync(date);
        return new AcademicContextAtDateDto(
            date,
            year is null ? null : ToPeriod(year.AcademicYearId, year.YearName, year.StartDate, year.EndDate),
            semester is null ? null : ToPeriod(semester.SemesterId, semester.SemesterName, semester.StartDate, semester.EndDate));
    }

    public async Task<StudentEnrollmentAtDateDto> GetStudentEnrollmentAtDateAsync(int studentId, DateOnly date)
    {
        var context = await GetContextAtDateAsync(date);
        var enrollment = await ResolveStudentEnrollmentAsync(studentId, date);
        return new StudentEnrollmentAtDateDto(date, context.AcademicYear, context.Semester, enrollment);
    }

    public async Task<StudentEnrollmentDto?> ResolveStudentEnrollmentAsync(int studentId, DateOnly date)
    {
        var year = await ResolveAcademicYearAsync(date);
        if (year is null) return null;

        var studentClass = await db.StudentClasses
            .Include(sc => sc.Class)
            .Include(sc => sc.Student)
            .FirstOrDefaultAsync(sc => sc.StudentId == studentId && sc.Class.AcademicYearId == year.AcademicYearId);

        if (studentClass is null) return null;

        return new StudentEnrollmentDto(
            studentClass.StudentClassId,
            studentClass.StudentId,
            studentClass.Student?.FullName,
            studentClass.Student?.Username,
            studentClass.ClassId,
            studentClass.Class.ClassName,
            year.AcademicYearId,
            year.YearName);
    }

    private static AcademicPeriodDto ToPeriod(int id, string name, DateOnly start, DateOnly end) =>
        new(id, name, start, end);
}
