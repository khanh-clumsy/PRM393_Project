using Microsoft.Extensions.Configuration;
using PRM393API.Common;
using PRM393API.Models;

namespace PRM393API.Tests.Helpers;

internal static class TestDataFactory
{
    internal const string DefaultPassword = "12345678";
    internal const string DefaultPhone = "0901000006";

    internal static IConfiguration CreateJwtConfiguration() =>
        new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Jwt:Key"] = "PRM393_SuperSecretKey_ChangeInProduction_AtLeast32Chars!",
                ["Jwt:Issuer"] = "PRM393API",
                ["Jwt:Audience"] = "PRM393Client",
            })
            .Build();

    internal static JwtHelper CreateJwtHelper() => new(CreateJwtConfiguration());

    internal static User CreateUser(
        string phone = DefaultPhone,
        string password = DefaultPassword,
        bool isActive = true,
        int userId = 1,
        int roleId = 4,
        string roleName = "Student") =>
        new()
        {
            UserId = userId,
            Username = $"user{userId}",
            PhoneNumber = phone,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(password),
            FullName = "Nguyễn Test",
            Email = "test@fschool.edu.vn",
            RoleId = roleId,
            Role = new Role { RoleId = roleId, RoleName = roleName },
            IsActive = isActive,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
        };

    internal static RefreshToken CreateRefreshToken(int userId, bool isRevoked = false, DateTime? expiresAt = null) =>
        new()
        {
            TokenId = 1,
            UserId = userId,
            Token = "valid-refresh-token",
            IsRevoked = isRevoked,
            ExpiresAt = expiresAt ?? DateTime.UtcNow.AddDays(7),
            CreatedAt = DateTime.UtcNow,
        };

    internal static AcademicYear CreateAcademicYear(int id = 1, bool isActive = true) =>
        new()
        {
            AcademicYearId = id,
            YearName = "2025-2026",
            StartDate = new DateOnly(2025, 9, 1),
            EndDate = new DateOnly(2026, 5, 31),
            IsActive = isActive,
        };

    internal static Semester CreateSemester(int id = 1, int academicYearId = 1) =>
        new()
        {
            SemesterId = id,
            AcademicYearId = academicYearId,
            SemesterName = "Học kỳ 1",
            StartDate = new DateOnly(2025, 9, 1),
            EndDate = new DateOnly(2026, 1, 15),
        };

    internal static Class CreateClass(int id = 1, int academicYearId = 1, int? homeroomTeacherId = null, string className = "10A1") =>
        new()
        {
            ClassId = id,
            ClassName = className,
            AcademicYearId = academicYearId,
            HomeroomTeacherId = homeroomTeacherId,
        };

    internal static Subject CreateSubject(int id = 1) =>
        new()
        {
            SubjectId = id,
            SubjectCode = "MATH",
            SubjectName = "Toán",
            IsActive = true,
        };

    internal static TeachingAssignment CreateTeachingAssignment(
        int id = 1, int teacherId = 3, int classId = 1, int subjectId = 1, int semesterId = 1) =>
        new()
        {
            TeachingAssignmentId = id,
            TeacherId = teacherId,
            ClassId = classId,
            SubjectId = subjectId,
            SemesterId = semesterId,
            Class = CreateClass(classId),
            Subject = CreateSubject(subjectId),
        };

    internal static StudentClass CreateStudentClass(int id = 1, int studentId = 10, int classId = 1) =>
        new()
        {
            StudentClassId = id,
            StudentId = studentId,
            ClassId = classId,
            Student = CreateUser(userId: studentId, roleId: 4, roleName: "Student"),
        };

    internal static Timetable CreateTimetable(int id = 1, int teachingAssignmentId = 1) =>
        new()
        {
            TimetableId = id,
            TeachingAssignmentId = teachingAssignmentId,
            Date = new DateOnly(2025, 10, 6),
            SlotId = 1,
            RoomName = "P101",
            Status = 1,
        };
}
