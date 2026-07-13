using PRM393API.Models;

namespace PRM393API.Tests.Helpers;

internal enum IntegrationSeedMode
{
    Full,
    Minimal,
}

/// <summary>
/// Dữ liệu mẫu tương đương seed migration — dùng cho integration tests map MOBILE_TEST_MATRIX.
/// </summary>
internal static class IntegrationScenarioSeed
{
    internal const int AdminId = 1;
    internal const int HeadOfDeptId = 2;
    internal const int Teacher01Id = 3;
    internal const int Teacher02Id = 4;
    internal const int Student01Id = 6;
    internal const int Student02Id = 7;
    internal const int Student03Id = 8;
    internal const int Parent01Id = 12;
    internal const int Class10A1Id = 1;
    internal const int Class10A2Id = 2;
    internal const int DeptToanId = 1;
    internal const int DeptVanId = 2;
    internal const int TeachingAssignmentMath10A1 = 1;
    internal const int SemesterHk1Id = 1;
    internal const int AssessmentType15MinId = 2;
    internal static readonly DateOnly TestDate = new(2025, 10, 6);

    internal static void Seed(Prm393dbContext db)
    {
        SeedCore(db);

        db.AcademicYears.Add(TestDataFactory.CreateAcademicYear(id: 1));
        db.Semesters.Add(TestDataFactory.CreateSemester(id: SemesterHk1Id));

        db.Subjects.AddRange(
            TestDataFactory.CreateSubject(id: 1),
            new Subject { SubjectId = 2, SubjectCode = "LIT", SubjectName = "Ngữ văn", IsActive = true });

        db.Classes.AddRange(
            TestDataFactory.CreateClass(id: Class10A1Id, homeroomTeacherId: Teacher01Id, className: "10A1"),
            TestDataFactory.CreateClass(id: Class10A2Id, homeroomTeacherId: Teacher02Id, className: "10A2"));

        db.TimetableSlots.AddRange(
            new TimetableSlot { SlotId = 1, SlotName = "Tiết 1", StartTime = new TimeOnly(7, 0), EndTime = new TimeOnly(7, 45) },
            new TimetableSlot { SlotId = 2, SlotName = "Tiết 2", StartTime = new TimeOnly(7, 50), EndTime = new TimeOnly(8, 35) });

        db.StudentClasses.AddRange(
            new StudentClass { StudentClassId = 1, StudentId = Student01Id, ClassId = Class10A1Id },
            new StudentClass { StudentClassId = 2, StudentId = Student02Id, ClassId = Class10A1Id });

        db.ParentStudents.Add(new ParentStudent
        {
            ParentStudentId = 1,
            ParentId = Parent01Id,
            StudentId = Student01Id,
            Relationship = "Cha",
        });

        db.TeachingAssignments.AddRange(
            new TeachingAssignment
            {
                TeachingAssignmentId = TeachingAssignmentMath10A1,
                TeacherId = Teacher01Id,
                ClassId = Class10A1Id,
                SubjectId = 1,
                SemesterId = SemesterHk1Id,
            },
            new TeachingAssignment
            {
                TeachingAssignmentId = 2,
                TeacherId = Teacher02Id,
                ClassId = Class10A1Id,
                SubjectId = 2,
                SemesterId = SemesterHk1Id,
            });

        db.Timetables.Add(new Timetable
        {
            TimetableId = 1,
            TeachingAssignmentId = TeachingAssignmentMath10A1,
            Date = TestDate,
            SlotId = 1,
            RoomName = "Phòng 101",
            Status = 1,
        });

        db.AssessmentTypes.AddRange(
            new AssessmentType { AssessmentTypeId = 1, TypeName = "Kiểm tra miệng", Weight = 0.1m },
            new AssessmentType { AssessmentTypeId = AssessmentType15MinId, TypeName = "Kiểm tra 15 phút", Weight = 0.2m });

        db.Assessments.Add(new Assessment
        {
            AssessmentId = 1,
            TeachingAssignmentId = TeachingAssignmentMath10A1,
            AssessmentTypeId = AssessmentType15MinId,
            AssessmentName = "KT 15 phút - Chương 1",
            AssessmentDate = new DateOnly(2025, 9, 20),
            MaxScore = 10m,
        });

        db.SaveChanges();
    }

    /// <summary>Chỉ roles, tổ, user — dùng E2E master từ đầu.</summary>
    internal static void SeedMinimal(Prm393dbContext db)
    {
        SeedCore(db);
        db.SaveChanges();
    }

    private static void SeedCore(Prm393dbContext db)
    {
        db.Roles.AddRange(
            new Role { RoleId = 1, RoleName = "Admin" },
            new Role { RoleId = 2, RoleName = "HeadOfDept" },
            new Role { RoleId = 3, RoleName = "Teacher" },
            new Role { RoleId = 4, RoleName = "Student" },
            new Role { RoleId = 5, RoleName = "Parent" });

        db.Departments.AddRange(
            new Department { DepartmentId = DeptToanId, DepartmentName = "Tổ Toán" },
            new Department { DepartmentId = DeptVanId, DepartmentName = "Tổ Văn" });

        var hash = BCrypt.Net.BCrypt.HashPassword(TestDataFactory.DefaultPassword);

        db.Users.AddRange(
            User(AdminId, "admin01", "0901000001", 1, null, hash),
            User(HeadOfDeptId, "hodept01", "0901000002", 2, DeptVanId, hash),
            User(Teacher01Id, "teacher01", "0901000003", 3, DeptToanId, hash),
            User(Teacher02Id, "teacher02", "0901000004", 3, DeptVanId, hash),
            User(Student01Id, "student01", "0901000006", 4, null, hash),
            User(Student02Id, "student02", "0901000007", 4, null, hash),
            User(Student03Id, "student03", "0901000008", 4, null, hash),
            User(Parent01Id, "parent01", "0912000001", 5, null, hash));
    }

    private static User User(int id, string username, string phone, int roleId, int? deptId, string hash) =>
        new()
        {
            UserId = id,
            Username = username,
            PhoneNumber = phone,
            PasswordHash = hash,
            FullName = username,
            Email = $"{username}@fschool.edu.vn",
            RoleId = roleId,
            DepartmentId = deptId,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
        };
}
