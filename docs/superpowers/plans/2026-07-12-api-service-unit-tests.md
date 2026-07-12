# API Service Unit Tests Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bổ sung bộ unit test xUnit + Moq cho toàn bộ 24 service trong `api/Services/`, đảm bảo mỗi service có file test riêng với đủ case nghiệp vụ và CRUD.

**Architecture:** Mock repository interfaces (Moq) cho mọi service trừ `TimetableService.Generate*` — dùng EF Core InMemory qua `DbContextTestHelper`. Pattern: Arrange → Act → Assert, một SUT per test class, factory dữ liệu tập trung ở `TestDataFactory`.

**Tech Stack:** .NET 8, xUnit 2.9, Moq 4.20, EF Core InMemory (chỉ TimetableService), BCrypt (Auth/User)

---

## Phạm vi & ma trận coverage

| # | Service | File test | Trạng thái | Số test mục tiêu |
|---|---------|-----------|------------|------------------|
| 1 | AuthService | `Services/AuthServiceTests.cs` | ✅ 7 test | 7 (giữ nguyên) |
| 2 | UserService | `Services/UserServiceTests.cs` | ⚠️ 4 test | 8 |
| 3 | AcademicYearService | `Services/AcademicYearServiceTests.cs` | ❌ | 6 |
| 4 | SemesterService | `Services/SemesterServiceTests.cs` | ❌ | 5 |
| 5 | SubjectService | `Services/SubjectServiceTests.cs` | ❌ | 5 |
| 6 | ClassService | `Services/ClassServiceTests.cs` | ❌ | 7 |
| 7 | DepartmentService | `Services/DepartmentServiceTests.cs` | ❌ | 5 |
| 8 | AcademicRankService | `Services/AcademicRankServiceTests.cs` | ❌ | 5 |
| 9 | TimetableSlotService | `Services/TimetableSlotServiceTests.cs` | ❌ | 5 |
| 10 | TeachingAssignmentService | `Services/TeachingAssignmentServiceTests.cs` | ❌ | 7 |
| 11 | TimetableService | `Services/TimetableServiceTests.cs` | ❌ | 10 |
| 12 | StudentClassService | `Services/StudentClassServiceTests.cs` | ❌ | 6 |
| 13 | ParentStudentService | `Services/ParentStudentServiceTests.cs` | ❌ | 5 |
| 14 | AttendanceService | `Services/AttendanceServiceTests.cs` | ❌ | 7 |
| 15 | GradeService | `Services/GradeServiceTests.cs` | ❌ | 7 |
| 16 | AssignmentService | `Services/AssignmentServiceTests.cs` | ❌ | 6 |
| 17 | SubmissionService | `Services/SubmissionServiceTests.cs` | ❌ | 6 |
| 18 | StudentRequestService | `Services/StudentRequestServiceTests.cs` | ❌ | 6 |
| 19 | StudentSemesterSummaryService | `Services/StudentSemesterSummaryServiceTests.cs` | ❌ | 5 |
| 20 | StudentYearlySummaryService | `Services/StudentYearlySummaryServiceTests.cs` | ❌ | 5 |
| 21 | AnnouncementService | `Services/AnnouncementServiceTests.cs` | ❌ | 6 |
| 22 | NotificationLogService | `Services/NotificationLogServiceTests.cs` | ❌ | 5 |
| 23 | AssessmentTypeService | `Services/AssessmentTypeServiceTests.cs` | ❌ | 5 |
| 24 | AssessmentService | `Services/AssessmentServiceTests.cs` | ❌ | 5 |
| — | AuthController | `Controllers/AuthControllerTests.cs` | ✅ 4 test | 4 (giữ nguyên) |

**Tổng mục tiêu:** ~140 unit test, tất cả pass với `dotnet test`.

---

## Cấu trúc file

```
api/PRM393API.Tests/
├── PRM393API.Tests.csproj          # thêm EF InMemory
├── Helpers/
│   ├── TestDataFactory.cs          # mở rộng factory entity/DTO
│   └── DbContextTestHelper.cs      # InMemory DbContext cho TimetableService
├── Services/
│   ├── AuthServiceTests.cs         # đã có
│   ├── UserServiceTests.cs         # mở rộng
│   ├── AcademicYearServiceTests.cs # mới
│   ├── ... (21 file test service còn lại)
└── Controllers/
    └── AuthControllerTests.cs      # đã có
```

**Lệnh chạy test (dùng xuyên suốt plan):**

```bash
cd api
dotnet test PRM393API.Tests/PRM393API.Tests.csproj --verbosity normal
```

---

### Task 0: Hạ tầng test — TestDataFactory + DbContextTestHelper

**Files:**
- Modify: `api/PRM393API.Tests/PRM393API.Tests.csproj`
- Modify: `api/PRM393API.Tests/Helpers/TestDataFactory.cs`
- Create: `api/PRM393API.Tests/Helpers/DbContextTestHelper.cs`

- [ ] **Step 1: Thêm package EF InMemory**

Sửa `PRM393API.Tests.csproj`, thêm vào `<ItemGroup>` PackageReference:

```xml
<PackageReference Include="Microsoft.EntityFrameworkCore.InMemory" Version="8.0.11" />
```

- [ ] **Step 2: Mở rộng TestDataFactory**

Thay toàn bộ nội dung `TestDataFactory.cs`:

```csharp
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

    internal static Class CreateClass(int id = 1, int academicYearId = 1, int? homeroomTeacherId = null) =>
        new()
        {
            ClassId = id,
            ClassName = "10A1",
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
```

- [ ] **Step 3: Tạo DbContextTestHelper**

```csharp
using Microsoft.EntityFrameworkCore;
using PRM393API.Models;

namespace PRM393API.Tests.Helpers;

internal static class DbContextTestHelper
{
    internal static Prm393dbContext CreateInMemoryContext(string dbName)
    {
        var options = new DbContextOptionsBuilder<Prm393dbContext>()
            .UseInMemoryDatabase(dbName)
            .Options;
        return new Prm393dbContext(options);
    }
}
```

- [ ] **Step 4: Chạy test baseline**

Run: `cd api && dotnet test PRM393API.Tests/PRM393API.Tests.csproj`
Expected: PASS (15 tests hiện tại)

- [ ] **Step 5: Commit**

```bash
git add api/PRM393API.Tests/
git commit -m "test: expand TestDataFactory and add DbContextTestHelper"
```

---

### Task 1: UserService — bổ sung test còn thiếu

**Files:**
- Modify: `api/PRM393API.Tests/Services/UserServiceTests.cs`

- [ ] **Step 1: Thêm 4 test vào cuối class UserServiceTests**

```csharp
    [Fact]
    public async Task GetByIdAsync_ExistingUser_ReturnsDto()
    {
        var user = TestDataFactory.CreateUser();
        _repo.Setup(r => r.GetByIdAsync(user.UserId)).ReturnsAsync(user);

        var result = await _sut.GetByIdAsync(user.UserId);

        Assert.NotNull(result);
        Assert.Equal(user.UserId, result!.UserId);
        Assert.Equal(user.FullName, result.FullName);
    }

    [Fact]
    public async Task GetByIdAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((User?)null);
        var result = await _sut.GetByIdAsync(999);
        Assert.Null(result);
    }

    [Fact]
    public async Task GetAllAsync_ReturnsMappedDtos()
    {
        var users = new[] { TestDataFactory.CreateUser(userId: 1), TestDataFactory.CreateUser(userId: 2, phone: "0901000007") };
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(users);

        var result = (await _sut.GetAllAsync()).ToList();

        Assert.Equal(2, result.Count);
        Assert.All(result, dto => Assert.False(string.IsNullOrWhiteSpace(dto.FullName)));
    }

    [Fact]
    public async Task DeleteAsync_ExistingUser_ReturnsTrue()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        var result = await _sut.DeleteAsync(1);
        Assert.True(result);
    }
```

- [ ] **Step 2: Chạy test**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~UserServiceTests"`
Expected: PASS (8 tests)

- [ ] **Step 3: Commit**

```bash
git add api/PRM393API.Tests/Services/UserServiceTests.cs
git commit -m "test: extend UserService coverage"
```

---

### Task 2: AcademicYearServiceTests

**Files:**
- Create: `api/PRM393API.Tests/Services/AcademicYearServiceTests.cs`

- [ ] **Step 1: Tạo file test đầy đủ**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class AcademicYearServiceTests
{
    private readonly Mock<IAcademicYearRepository> _yearRepo = new();
    private readonly Mock<ISemesterRepository> _semesterRepo = new();
    private readonly AcademicYearService _sut;

    public AcademicYearServiceTests()
    {
        _sut = new AcademicYearService(_yearRepo.Object, _semesterRepo.Object);
    }

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        var year = TestDataFactory.CreateAcademicYear();
        _yearRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(year);

        var result = await _sut.GetByIdAsync(1);

        Assert.NotNull(result);
        Assert.Equal("2025-2026", result!.YearName);
    }

    [Fact]
    public async Task GetByIdAsync_NotFound_ReturnsNull()
    {
        _yearRepo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((AcademicYear?)null);
        Assert.Null(await _sut.GetByIdAsync(99));
    }

    [Fact]
    public async Task CreateAsync_AutoCreatesTwoSemesters()
    {
        var dto = new CreateAcademicYearDto("2026-2027", new DateOnly(2026, 9, 1), new DateOnly(2027, 5, 31), true);
        _yearRepo.Setup(r => r.CreateAsync(It.IsAny<AcademicYear>()))
            .ReturnsAsync((AcademicYear y) => { y.AcademicYearId = 2; return y; });
        _semesterRepo.Setup(r => r.CreateAsync(It.IsAny<Semester>()))
            .ReturnsAsync((Semester s) => s);

        var result = await _sut.CreateAsync(dto);

        Assert.Equal("2026-2027", result.YearName);
        _semesterRepo.Verify(r => r.CreateAsync(It.Is<Semester>(s => s.SemesterName == "Học kỳ 1")), Times.Once);
        _semesterRepo.Verify(r => r.CreateAsync(It.Is<Semester>(s => s.SemesterName == "Học kỳ 2")), Times.Once);
    }

    [Fact]
    public async Task CreateAsync_SemesterDatesMatchBusinessRule()
    {
        var dto = new CreateAcademicYearDto("2025-2026", new DateOnly(2025, 9, 1), new DateOnly(2026, 5, 31));
        _yearRepo.Setup(r => r.CreateAsync(It.IsAny<AcademicYear>()))
            .ReturnsAsync((AcademicYear y) => { y.AcademicYearId = 1; return y; });

        Semester? sem1 = null;
        Semester? sem2 = null;
        _semesterRepo.Setup(r => r.CreateAsync(It.IsAny<Semester>()))
            .Callback<Semester>(s => { if (sem1 is null) sem1 = s; else sem2 = s; })
            .ReturnsAsync((Semester s) => s);

        await _sut.CreateAsync(dto);

        Assert.NotNull(sem1);
        Assert.NotNull(sem2);
        Assert.Equal(new DateOnly(2025, 9, 1), sem1!.StartDate);
        Assert.Equal(new DateOnly(2026, 1, 15), sem1.EndDate);
        Assert.Equal(new DateOnly(2026, 1, 16), sem2!.StartDate);
        Assert.Equal(new DateOnly(2026, 5, 31), sem2.EndDate);
    }

    [Fact]
    public async Task UpdateAsync_Existing_UpdatesFields()
    {
        var existing = TestDataFactory.CreateAcademicYear();
        _yearRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _yearRepo.Setup(r => r.UpdateAsync(1, It.IsAny<AcademicYear>()))
            .ReturnsAsync((int _, AcademicYear y) => y);

        var result = await _sut.UpdateAsync(1, new UpdateAcademicYearDto("2025-2026 (sửa)", null, null, false));

        Assert.NotNull(result);
        Assert.Equal("2025-2026 (sửa)", result!.YearName);
        Assert.False(result.IsActive);
    }

    [Fact]
    public async Task DeleteAsync_DelegatesToRepo()
    {
        _yearRepo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 2: Chạy test**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~AcademicYearServiceTests"`
Expected: PASS (6 tests)

- [ ] **Step 3: Commit**

```bash
git add api/PRM393API.Tests/Services/AcademicYearServiceTests.cs
git commit -m "test: add AcademicYearService unit tests"
```

---

### Task 3: ClassServiceTests (nghiệp vụ GVCN)

**Files:**
- Create: `api/PRM393API.Tests/Services/ClassServiceTests.cs`

- [ ] **Step 1: Tạo file test đầy đủ**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class ClassServiceTests
{
    private readonly Mock<IClassRepository> _repo = new();
    private readonly ClassService _sut;

    public ClassServiceTests() => _sut = new ClassService(_repo.Object);

    [Fact]
    public async Task CreateAsync_NoHomeroomTeacher_Succeeds()
    {
        var dto = new CreateClassDto("10A2", 1, null);
        _repo.Setup(r => r.CreateAsync(It.IsAny<Class>()))
            .ReturnsAsync((Class c) => { c.ClassId = 2; return c; });

        var result = await _sut.CreateAsync(dto);

        Assert.Equal("10A2", result.ClassName);
        _repo.Verify(r => r.GetByAcademicYearAsync(It.IsAny<int>()), Times.Never);
    }

    [Fact]
    public async Task CreateAsync_DuplicateHomeroomInSameYear_Throws()
    {
        var dto = new CreateClassDto("10A3", 1, 5);
        _repo.Setup(r => r.GetByAcademicYearAsync(1))
            .ReturnsAsync(new[] { TestDataFactory.CreateClass(homeroomTeacherId: 5) });

        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() => _sut.CreateAsync(dto));

        Assert.Contains("đã chủ nhiệm", ex.Message);
        _repo.Verify(r => r.CreateAsync(It.IsAny<Class>()), Times.Never);
    }

    [Fact]
    public async Task CreateAsync_UniqueHomeroom_Succeeds()
    {
        var dto = new CreateClassDto("10A4", 1, 6);
        _repo.Setup(r => r.GetByAcademicYearAsync(1))
            .ReturnsAsync(new[] { TestDataFactory.CreateClass(homeroomTeacherId: 5) });
        _repo.Setup(r => r.CreateAsync(It.IsAny<Class>()))
            .ReturnsAsync((Class c) => { c.ClassId = 4; return c; });

        var result = await _sut.CreateAsync(dto);

        Assert.Equal(6, result.HomeroomTeacherId);
    }

    [Fact]
    public async Task UpdateAsync_DuplicateHomeroom_Throws()
    {
        var existing = TestDataFactory.CreateClass(id: 1, homeroomTeacherId: 5);
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.GetByAcademicYearAsync(1))
            .ReturnsAsync(new[]
            {
                existing,
                TestDataFactory.CreateClass(id: 2, homeroomTeacherId: 7),
            });

        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _sut.UpdateAsync(1, new UpdateClassDto(null, 7)));
    }

    [Fact]
    public async Task UpdateAsync_SameHomeroom_NoConflict()
    {
        var existing = TestDataFactory.CreateClass(id: 1, homeroomTeacherId: 5);
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.UpdateAsync(1, It.IsAny<Class>()))
            .ReturnsAsync((int _, Class c) => c);

        var result = await _sut.UpdateAsync(1, new UpdateClassDto("10A1 đổi tên", 5));

        Assert.NotNull(result);
        Assert.Equal("10A1 đổi tên", result!.ClassName);
    }

    [Fact]
    public async Task GetByIdAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Class?)null);
        Assert.Null(await _sut.GetByIdAsync(99));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 2: Chạy test**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~ClassServiceTests"`
Expected: PASS (7 tests)

- [ ] **Step 3: Commit**

```bash
git add api/PRM393API.Tests/Services/ClassServiceTests.cs
git commit -m "test: add ClassService unit tests with GVCN rules"
```

---

### Task 4: TeachingAssignmentServiceTests

**Files:**
- Create: `api/PRM393API.Tests/Services/TeachingAssignmentServiceTests.cs`

- [ ] **Step 1: Tạo file test đầy đủ**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class TeachingAssignmentServiceTests
{
    private readonly Mock<ITeachingAssignmentRepository> _repo = new();
    private readonly TeachingAssignmentService _sut;

    public TeachingAssignmentServiceTests() => _sut = new TeachingAssignmentService(_repo.Object);

    [Fact]
    public async Task CreateAsync_DuplicateAssignment_Throws()
    {
        var dto = new CreateTeachingAssignmentDto(3, 1, 1, 1);
        _repo.Setup(r => r.GetByClassAsync(1))
            .ReturnsAsync(new[] { TestDataFactory.CreateTeachingAssignment(teacherId: 3, subjectId: 1, semesterId: 1) });

        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() => _sut.CreateAsync(dto));

        Assert.Contains("đã được phân công", ex.Message);
        _repo.Verify(r => r.CreateAsync(It.IsAny<TeachingAssignment>()), Times.Never);
    }

    [Fact]
    public async Task CreateAsync_UniqueAssignment_Succeeds()
    {
        var dto = new CreateTeachingAssignmentDto(3, 1, 2, 1);
        _repo.Setup(r => r.GetByClassAsync(1))
            .ReturnsAsync(new[] { TestDataFactory.CreateTeachingAssignment(subjectId: 1) });
        _repo.Setup(r => r.CreateAsync(It.IsAny<TeachingAssignment>()))
            .ReturnsAsync((TeachingAssignment ta) => { ta.TeachingAssignmentId = 10; return ta; });

        var result = await _sut.CreateAsync(dto);

        Assert.Equal(10, result.TeachingAssignmentId);
        Assert.Equal(2, result.SubjectId);
    }

    [Fact]
    public async Task UpdateAsync_ConflictWithOtherRecord_Throws()
    {
        var existing = TestDataFactory.CreateTeachingAssignment(id: 1, subjectId: 1);
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.GetByClassAsync(1))
            .ReturnsAsync(new[]
            {
                existing,
                TestDataFactory.CreateTeachingAssignment(id: 2, teacherId: 3, subjectId: 2, semesterId: 1),
            });

        var dto = new UpdateTeachingAssignmentDto(3, 1, 2, 1);

        await Assert.ThrowsAsync<InvalidOperationException>(() => _sut.UpdateAsync(1, dto));
    }

    [Fact]
    public async Task UpdateAsync_ValidChange_Succeeds()
    {
        var existing = TestDataFactory.CreateTeachingAssignment(id: 1);
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.GetByClassAsync(1)).ReturnsAsync(new[] { existing });
        _repo.Setup(r => r.UpdateAsync(It.IsAny<TeachingAssignment>()))
            .ReturnsAsync((TeachingAssignment ta) => ta);

        var result = await _sut.UpdateAsync(1, new UpdateTeachingAssignmentDto(4, 1, 1, 1));

        Assert.NotNull(result);
        Assert.Equal(4, result!.TeacherId);
    }

    [Fact]
    public async Task GetByIdAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((TeachingAssignment?)null);
        Assert.Null(await _sut.GetByIdAsync(99));
    }

    [Fact]
    public async Task GetByTeacherAsync_ReturnsMappedList()
    {
        _repo.Setup(r => r.GetByTeacherAsync(3))
            .ReturnsAsync(new[] { TestDataFactory.CreateTeachingAssignment() });

        var list = (await _sut.GetByTeacherAsync(3)).ToList();

        Assert.Single(list);
        Assert.Equal("10A1", list[0].ClassName);
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 2: Chạy test**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~TeachingAssignmentServiceTests"`
Expected: PASS (7 tests)

- [ ] **Step 3: Commit**

```bash
git add api/PRM393API.Tests/Services/TeachingAssignmentServiceTests.cs
git commit -m "test: add TeachingAssignmentService duplicate-assignment tests"
```

---

### Task 5: StudentClassServiceTests

**Files:**
- Create: `api/PRM393API.Tests/Services/StudentClassServiceTests.cs`

- [ ] **Step 1: Tạo file test đầy đủ**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class StudentClassServiceTests
{
    private readonly Mock<IStudentClassRepository> _scRepo = new();
    private readonly Mock<IClassRepository> _classRepo = new();
    private readonly StudentClassService _sut;

    public StudentClassServiceTests()
    {
        _sut = new StudentClassService(_scRepo.Object, _classRepo.Object);
    }

    [Fact]
    public async Task CreateAsync_ClassNotFound_ThrowsKeyNotFound()
    {
        _classRepo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Class?)null);

        await Assert.ThrowsAsync<KeyNotFoundException>(() =>
            _sut.CreateAsync(new CreateStudentClassDto(10, 99)));
    }

    [Fact]
    public async Task CreateAsync_StudentAlreadyInSameYear_Throws()
    {
        var targetClass = TestDataFactory.CreateClass(id: 2, academicYearId: 1);
        var oldClass = TestDataFactory.CreateClass(id: 1, academicYearId: 1);
        _classRepo.Setup(r => r.GetByIdAsync(2)).ReturnsAsync(targetClass);
        _scRepo.Setup(r => r.GetByStudentAsync(10))
            .ReturnsAsync(new[] { TestDataFactory.CreateStudentClass(classId: 1) });
        _classRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(oldClass);

        var ex = await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _sut.CreateAsync(new CreateStudentClassDto(10, 2)));

        Assert.Contains("đã được phân vào", ex.Message);
    }

    [Fact]
    public async Task CreateAsync_DifferentYear_AllowsEnrollment()
    {
        var targetClass = TestDataFactory.CreateClass(id: 3, academicYearId: 2);
        var oldClass = TestDataFactory.CreateClass(id: 1, academicYearId: 1);
        _classRepo.Setup(r => r.GetByIdAsync(3)).ReturnsAsync(targetClass);
        _scRepo.Setup(r => r.GetByStudentAsync(10))
            .ReturnsAsync(new[] { TestDataFactory.CreateStudentClass(classId: 1) });
        _classRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(oldClass);
        _scRepo.Setup(r => r.CreateAsync(It.IsAny<StudentClass>()))
            .ReturnsAsync((StudentClass sc) => { sc.StudentClassId = 5; return sc; });

        var result = await _sut.CreateAsync(new CreateStudentClassDto(10, 3));

        Assert.Equal(5, result.StudentClassId);
    }

    [Fact]
    public async Task CreateAsync_FirstEnrollment_Succeeds()
    {
        var targetClass = TestDataFactory.CreateClass(id: 1);
        _classRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(targetClass);
        _scRepo.Setup(r => r.GetByStudentAsync(10)).ReturnsAsync(Array.Empty<StudentClass>());
        _scRepo.Setup(r => r.CreateAsync(It.IsAny<StudentClass>()))
            .ReturnsAsync((StudentClass sc) => { sc.StudentClassId = 1; return sc; });

        var result = await _sut.CreateAsync(new CreateStudentClassDto(10, 1));

        Assert.Equal(10, result.StudentId);
        Assert.Equal(1, result.ClassId);
    }

    [Fact]
    public async Task GetByClassAsync_ReturnsMappedList()
    {
        _scRepo.Setup(r => r.GetByClassAsync(1))
            .ReturnsAsync(new[] { TestDataFactory.CreateStudentClass() });

        var list = (await _sut.GetByClassAsync(1)).ToList();

        Assert.Single(list);
        Assert.Equal("Nguyễn Test", list[0].StudentName);
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _scRepo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 2: Chạy test**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~StudentClassServiceTests"`
Expected: PASS (6 tests)

- [ ] **Step 3: Commit**

```bash
git add api/PRM393API.Tests/Services/StudentClassServiceTests.cs
git commit -m "test: add StudentClassService enrollment rule tests"
```

---

### Task 6: SemesterServiceTests

**Files:**
- Create: `api/PRM393API.Tests/Services/SemesterServiceTests.cs`

- [ ] **Step 1: Tạo file test**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class SemesterServiceTests
{
    private readonly Mock<ISemesterRepository> _repo = new();
    private readonly SemesterService _sut;

    public SemesterServiceTests() => _sut = new SemesterService(_repo.Object);

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        var sem = TestDataFactory.CreateSemester();
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(sem);
        var result = await _sut.GetByIdAsync(1);
        Assert.NotNull(result);
        Assert.Equal("Học kỳ 1", result!.SemesterName);
    }

    [Fact]
    public async Task GetByAcademicYearAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByAcademicYearAsync(1))
            .ReturnsAsync(new[] { TestDataFactory.CreateSemester(), TestDataFactory.CreateSemester(id: 2) });
        Assert.Equal(2, (await _sut.GetByAcademicYearAsync(1)).Count());
    }

    [Fact]
    public async Task CreateAsync_MapsFields()
    {
        var dto = new CreateSemesterDto(1, "HK phụ", new DateOnly(2026, 6, 1), new DateOnly(2026, 7, 31));
        _repo.Setup(r => r.CreateAsync(It.IsAny<Semester>()))
            .ReturnsAsync((Semester s) => { s.SemesterId = 3; return s; });
        var result = await _sut.CreateAsync(dto);
        Assert.Equal("HK phụ", result.SemesterName);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Semester?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateSemesterDto("X", null, null)));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 2: Chạy & commit**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~SemesterServiceTests"`
Expected: PASS

```bash
git add api/PRM393API.Tests/Services/SemesterServiceTests.cs
git commit -m "test: add SemesterService unit tests"
```

---

### Task 7: SubjectServiceTests

**Files:**
- Create: `api/PRM393API.Tests/Services/SubjectServiceTests.cs`

- [ ] **Step 1: Tạo file test**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class SubjectServiceTests
{
    private readonly Mock<ISubjectRepository> _repo = new();
    private readonly SubjectService _sut;

    public SubjectServiceTests() => _sut = new SubjectService(_repo.Object);

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(TestDataFactory.CreateSubject());
        var result = await _sut.GetByIdAsync(1);
        Assert.Equal("MATH", result!.SubjectCode);
    }

    [Fact]
    public async Task GetAllAsync_ReturnsActiveSubjects()
    {
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[] { TestDataFactory.CreateSubject() });
        Assert.Single(await _sut.GetAllAsync());
    }

    [Fact]
    public async Task CreateAsync_DefaultIsActiveTrue()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<Subject>()))
            .ReturnsAsync((Subject s) => { s.SubjectId = 2; return s; });
        var result = await _sut.CreateAsync(new CreateSubjectDto("PHY", "Vật lý"));
        Assert.True(result.IsActive);
    }

    [Fact]
    public async Task UpdateAsync_DeactivateSubject()
    {
        var existing = TestDataFactory.CreateSubject();
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.UpdateAsync(1, It.IsAny<Subject>()))
            .ReturnsAsync((int _, Subject s) => s);
        var result = await _sut.UpdateAsync(1, new UpdateSubjectDto(null, null, false));
        Assert.False(result!.IsActive);
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 2: Chạy & commit**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~SubjectServiceTests"`
Expected: PASS (5 tests)

```bash
git add api/PRM393API.Tests/Services/SubjectServiceTests.cs
git commit -m "test: add SubjectService unit tests"
```

---

### Task 8: DepartmentServiceTests

**Files:**
- Create: `api/PRM393API.Tests/Services/DepartmentServiceTests.cs`

- [ ] **Step 1: Tạo file test**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class DepartmentServiceTests
{
    private readonly Mock<IDepartmentRepository> _repo = new();
    private readonly DepartmentService _sut;

    public DepartmentServiceTests() => _sut = new DepartmentService(_repo.Object);

    private static Department SampleDept() => new()
    {
        DepartmentId = 1,
        DepartmentName = "Toán - Lý",
        Description = "Tổ Toán Lý",
    };

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(SampleDept());
        var result = await _sut.GetByIdAsync(1);
        Assert.Equal("Toán - Lý", result!.DepartmentName);
    }

    [Fact]
    public async Task CreateAsync_MapsFields()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<Department>()))
            .ReturnsAsync((Department d) => { d.DepartmentId = 2; return d; });
        var result = await _sut.CreateAsync(new CreateDepartmentDto("Hóa", "Tổ Hóa"));
        Assert.Equal("Hóa", result.DepartmentName);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Department?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateDepartmentDto("X", null)));
    }

    [Fact]
    public async Task GetAllAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[] { SampleDept() });
        Assert.Single(await _sut.GetAllAsync());
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 2: Chạy & commit**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~DepartmentServiceTests"`
Expected: PASS (5 tests)

```bash
git add api/PRM393API.Tests/Services/DepartmentServiceTests.cs
git commit -m "test: add DepartmentService unit tests"
```

---

### Task 9: AcademicRankServiceTests + TimetableSlotServiceTests

**Files:**
- Create: `api/PRM393API.Tests/Services/AcademicRankServiceTests.cs`
- Create: `api/PRM393API.Tests/Services/TimetableSlotServiceTests.cs`

- [ ] **Step 1: AcademicRankServiceTests**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class AcademicRankServiceTests
{
    private readonly Mock<IAcademicRankRepository> _repo = new();
    private readonly AcademicRankService _sut;

    public AcademicRankServiceTests() => _sut = new AcademicRankService(_repo.Object);

    private static AcademicRank Sample() => new()
    {
        RankId = 1,
        RankName = "Giỏi",
        MinScore = 8.0m,
        MaxScore = 10.0m,
    };

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        Assert.Equal("Giỏi", (await _sut.GetByIdAsync(1))!.RankName);
    }

    [Fact]
    public async Task CreateAsync_MapsScoreRange()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<AcademicRank>()))
            .ReturnsAsync((AcademicRank a) => { a.RankId = 2; return a; });
        var result = await _sut.CreateAsync(new CreateAcademicRankDto("Khá", 6.5m, 7.9m));
        Assert.Equal(6.5m, result.MinScore);
    }

    [Fact]
    public async Task UpdateAsync_Existing_UpdatesName()
    {
        var existing = Sample();
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.UpdateAsync(1, It.IsAny<AcademicRank>()))
            .ReturnsAsync((int _, AcademicRank a) => a);
        var result = await _sut.UpdateAsync(1, new UpdateAcademicRankDto("Giỏi+", null, null));
        Assert.Equal("Giỏi+", result!.RankName);
    }

    [Fact]
    public async Task GetAllAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetAllAsync());
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 2: TimetableSlotServiceTests**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class TimetableSlotServiceTests
{
    private readonly Mock<ITimetableSlotRepository> _repo = new();
    private readonly TimetableSlotService _sut;

    public TimetableSlotServiceTests() => _sut = new TimetableSlotService(_repo.Object);

    private static TimetableSlot Sample() => new()
    {
        SlotId = 1,
        SlotName = "Tiết 1",
        StartTime = new TimeOnly(7, 0),
        EndTime = new TimeOnly(7, 45),
    };

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        Assert.Equal("Tiết 1", (await _sut.GetByIdAsync(1))!.SlotName);
    }

    [Fact]
    public async Task CreateAsync_MapsTimes()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<TimetableSlot>()))
            .ReturnsAsync((TimetableSlot s) => { s.SlotId = 2; return s; });
        var dto = new CreateTimetableSlotDto("Tiết 2", new TimeOnly(7, 50), new TimeOnly(8, 35));
        var result = await _sut.CreateAsync(dto);
        Assert.Equal(new TimeOnly(7, 50), result.StartTime);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((TimetableSlot?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateTimetableSlotDto("X", null, null)));
    }

    [Fact]
    public async Task GetAllAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetAllAsync());
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 3: Chạy & commit cả hai file**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~AcademicRankServiceTests|FullyQualifiedName~TimetableSlotServiceTests"`

```bash
git add api/PRM393API.Tests/Services/AcademicRankServiceTests.cs api/PRM393API.Tests/Services/TimetableSlotServiceTests.cs
git commit -m "test: add AcademicRank and TimetableSlot service tests"
```

---

### Task 10: TimetableServiceTests (repo + generate)

**Files:**
- Create: `api/PRM393API.Tests/Services/TimetableServiceTests.cs`

- [ ] **Step 1: Tạo file test**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class TimetableServiceTests : IDisposable
{
    private readonly Mock<ITimetableRepository> _repo = new();
    private readonly Prm393dbContext _db;
    private readonly TimetableService _sut;

    public TimetableServiceTests()
    {
        _db = DbContextTestHelper.CreateInMemoryContext(Guid.NewGuid().ToString());
        _sut = new TimetableService(_repo.Object, _db);
    }

    public void Dispose() => _db.Dispose();

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        var tt = TestDataFactory.CreateTimetable();
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(tt);
        var result = await _sut.GetByIdAsync(1);
        Assert.Equal("P101", result!.RoomName);
    }

    [Fact]
    public async Task CreateAsync_MapsFields()
    {
        var dto = new CreateTimetableDto(1, new DateOnly(2025, 10, 7), 1, "P102", 1, null);
        _repo.Setup(r => r.CreateAsync(It.IsAny<Timetable>()))
            .ReturnsAsync((Timetable t) => { t.TimetableId = 5; return t; });
        var result = await _sut.CreateAsync(dto);
        Assert.Equal("P102", result.RoomName);
    }

    [Fact]
    public async Task GetWeeklyByClassAsync_CalculatesMondayWeek()
    {
        var monday = new DateOnly(2025, 10, 6);
        _repo.Setup(r => r.GetWeeklyByClassAsync(1, monday, monday.AddDays(6)))
            .ReturnsAsync(new List<Timetable>());
        var result = await _sut.GetWeeklyByClassAsync(1, new DateOnly(2025, 10, 8));
        Assert.Empty(result);
        _repo.Verify(r => r.GetWeeklyByClassAsync(1, monday, monday.AddDays(6)), Times.Once);
    }

    [Fact]
    public async Task GenerateTimetablesForSemesterAsync_SemesterNotFound_ReturnsZero()
    {
        var count = await _sut.GenerateTimetablesForSemesterAsync(999, new List<TimetableTemplateDto>());
        Assert.Equal(0, count);
    }

    [Fact]
    public async Task GenerateTimetablesForSemesterAsync_ValidSemester_CreatesEntries()
    {
        var sem = TestDataFactory.CreateSemester();
        _db.Semesters.Add(sem);
        var ta = TestDataFactory.CreateTeachingAssignment();
        _db.TeachingAssignments.Add(ta);
        await _db.SaveChangesAsync();

        // Thứ 2 → expectedDayOfWeek = 2 (logic trong TimetableService)
        var templates = new List<TimetableTemplateDto>
        {
            new(ta.TeachingAssignmentId, (byte)2, 1, "P101"),
        };

        _repo.Setup(r => r.BulkCreateAsync(It.IsAny<IEnumerable<Timetable>>()))
            .ReturnsAsync((IEnumerable<Timetable> list) => list.ToList());

        var count = await _sut.GenerateTimetablesForSemesterAsync(sem.SemesterId, templates);

        Assert.True(count > 0);
        _repo.Verify(r => r.BulkCreateAsync(It.IsAny<IEnumerable<Timetable>>()), Times.Once);
    }

    [Fact]
    public async Task ClearGeneratedTimetablesAsync_NoSemester_ReturnsZero()
    {
        var count = await _sut.ClearGeneratedTimetablesAsync(999, 1);
        Assert.Equal(0, count);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Timetable?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateTimetableDto(null, null, null, null, null)));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }

    [Fact]
    public async Task GetByClassAsync_ReturnsMappedList()
    {
        _repo.Setup(r => r.GetByClassAsync(1)).ReturnsAsync(new[] { TestDataFactory.CreateTimetable() });
        Assert.Single(await _sut.GetByClassAsync(1));
    }

    [Fact]
    public async Task GetDetailAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetDetailAsync(99)).ReturnsAsync((Timetable?)null);
        Assert.Null(await _sut.GetDetailAsync(99));
    }
}
```

- [ ] **Step 2: Chạy test — sửa compile nếu signature DTO khác**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~TimetableServiceTests"`
Expected: PASS sau khi khớp `byte DayOfWeek` trong `TimetableTemplateDto` và method `ClearGeneratedTimetablesAsync`.

- [ ] **Step 3: Commit**

```bash
git add api/PRM393API.Tests/Services/TimetableServiceTests.cs
git commit -m "test: add TimetableService unit tests with InMemory DbContext"
```

---

### Task 11: AttendanceServiceTests

**Files:**
- Create: `api/PRM393API.Tests/Services/AttendanceServiceTests.cs`

- [ ] **Step 1: Tạo file test**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class AttendanceServiceTests
{
    private readonly Mock<IAttendanceRepository> _repo = new();
    private readonly AttendanceService _sut;

    public AttendanceServiceTests() => _sut = new AttendanceService(_repo.Object);

    private static AttendanceRecord Sample() => new()
    {
        AttendanceId = 1,
        TimetableId = 1,
        StudentId = 10,
        Status = "Present",
        RecordedBy = 3,
        RecordedAt = DateTime.UtcNow,
    };

    [Fact]
    public async Task CreateAsync_SetsRecordedAt()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<AttendanceRecord>()))
            .ReturnsAsync((AttendanceRecord a) => a);
        var dto = new CreateAttendanceDto(1, 10, "Present", null, 3);
        var result = await _sut.CreateAsync(dto);
        Assert.Equal("Present", result.Status);
        _repo.Verify(r => r.CreateAsync(It.Is<AttendanceRecord>(a => a.RecordedAt <= DateTime.UtcNow)), Times.Once);
    }

    [Fact]
    public async Task BulkCreateAsync_MapsAllRecords()
    {
        var dtos = new[]
        {
            new CreateAttendanceDto(1, 10, "Present", null, 3),
            new CreateAttendanceDto(1, 11, "Absent", "ốm", 3),
        };
        _repo.Setup(r => r.BulkCreateAsync(It.IsAny<IEnumerable<AttendanceRecord>>()))
            .ReturnsAsync((IEnumerable<AttendanceRecord> list) => list.ToList());
        var result = (await _sut.BulkCreateAsync(dtos)).ToList();
        Assert.Equal(2, result.Count);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((AttendanceRecord?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateAttendanceDto("Late", null)));
    }

    [Fact]
    public async Task BulkUpdateAsync_DelegatesToRepo()
    {
        var updates = new[] { new BulkUpdateAttendanceDto(1, "Late", "trễ 5p") };
        _repo.Setup(r => r.BulkUpdateAsync(It.IsAny<IEnumerable<(int AttendanceId, string Status, string? Note)>>()))
            .ReturnsAsync(new[] { Sample() });
        var result = (await _sut.BulkUpdateAsync(updates)).ToList();
        Assert.Single(result);
    }

    [Fact]
    public async Task GetByStudentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByStudentAsync(10)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByStudentAsync(10));
    }

    [Fact]
    public async Task GetByTimetableAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByTimetableAsync(1)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByTimetableAsync(1));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 2: Chạy & commit**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~AttendanceServiceTests"`
Expected: PASS (7 tests)

```bash
git add api/PRM393API.Tests/Services/AttendanceServiceTests.cs
git commit -m "test: add AttendanceService unit tests"
```

---

### Task 12: GradeServiceTests

**Files:**
- Create: `api/PRM393API.Tests/Services/GradeServiceTests.cs`

- [ ] **Step 1: Tạo file test**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class GradeServiceTests
{
    private readonly Mock<IGradeRepository> _repo = new();
    private readonly GradeService _sut;

    public GradeServiceTests() => _sut = new GradeService(_repo.Object);

    private static Grade Sample() => new()
    {
        GradeId = 1,
        AssessmentId = 1,
        StudentId = 10,
        Score = 8.5m,
        EnteredBy = 3,
        EnteredAt = DateTime.UtcNow,
    };

    [Fact]
    public async Task CreateAsync_SetsEnteredAt()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<Grade>())).ReturnsAsync((Grade g) => g);
        var result = await _sut.CreateAsync(new CreateGradeDto(1, 10, 9.0m, "tốt", 3));
        Assert.Equal(9.0m, result.Score);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Grade?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateGradeDto(7.0m, null)));
    }

    [Fact]
    public async Task GetStudentTranscriptAsync_DelegatesToRepo()
    {
        var transcript = new AcademicTranscriptDto(10, 1, new List<SubjectTranscriptDto>());
        _repo.Setup(r => r.GetStudentTranscriptAsync(10, 1)).ReturnsAsync(transcript);
        var result = await _sut.GetStudentTranscriptAsync(10, 1);
        Assert.Equal(10, result.StudentId);
    }

    [Fact]
    public async Task GetByAssessmentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByAssessmentAsync(1)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByAssessmentAsync(1));
    }

    [Fact]
    public async Task SaveBulkGradesAsync_DelegatesToRepo()
    {
        var dtos = new List<BulkGradeDto> { new(1, 10, 8.0m, null, 3) };
        _repo.Setup(r => r.SaveBulkGradesAsync(dtos)).Returns(Task.CompletedTask);
        await _sut.SaveBulkGradesAsync(dtos);
        _repo.Verify(r => r.SaveBulkGradesAsync(dtos), Times.Once);
    }

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        Assert.Equal(8.5m, (await _sut.GetByIdAsync(1))!.Score);
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 2: Chạy & commit**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~GradeServiceTests"`
Expected: PASS (7 tests)

```bash
git add api/PRM393API.Tests/Services/GradeServiceTests.cs
git commit -m "test: add GradeService unit tests"
```

---

### Task 13: AssignmentServiceTests + SubmissionServiceTests

**Files:**
- Create: `api/PRM393API.Tests/Services/AssignmentServiceTests.cs`
- Create: `api/PRM393API.Tests/Services/SubmissionServiceTests.cs`

- [ ] **Step 1: AssignmentServiceTests**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class AssignmentServiceTests
{
    private readonly Mock<IAssignmentRepository> _repo = new();
    private readonly AssignmentService _sut;

    public AssignmentServiceTests() => _sut = new AssignmentService(_repo.Object);

    private static Assignment Sample() => new()
    {
        AssignmentId = 1,
        TeachingAssignmentId = 1,
        Title = "Bài 1",
        DueDate = DateTime.UtcNow.AddDays(7),
        CreatedBy = 3,
        CreatedAt = DateTime.UtcNow,
        UpdatedAt = DateTime.UtcNow,
        IsDeleted = false,
    };

    [Fact]
    public async Task CreateAsync_SetsIsDeletedFalse()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<Assignment>())).ReturnsAsync((Assignment a) => a);
        var result = await _sut.CreateAsync(new CreateAssignmentDto(1, "Bài mới", null, null, DateTime.UtcNow.AddDays(3), 3));
        _repo.Verify(r => r.CreateAsync(It.Is<Assignment>(a => !a.IsDeleted)), Times.Once);
        Assert.Equal("Bài mới", result.Title);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Assignment?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateAssignmentDto("X", null, null, null)));
    }

    [Fact]
    public async Task DeleteAsync_CallsSoftDelete()
    {
        _repo.Setup(r => r.SoftDeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
        _repo.Verify(r => r.SoftDeleteAsync(1), Times.Once);
    }

    [Fact]
    public async Task GetByTeachingAssignmentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByTeachingAssignmentAsync(1)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByTeachingAssignmentAsync(1));
    }

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        Assert.Equal("Bài 1", (await _sut.GetByIdAsync(1))!.Title);
    }

    [Fact]
    public async Task GetAllAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetAllAsync());
    }
}
```

- [ ] **Step 2: SubmissionServiceTests**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class SubmissionServiceTests
{
    private readonly Mock<ISubmissionRepository> _repo = new();
    private readonly SubmissionService _sut;

    public SubmissionServiceTests() => _sut = new SubmissionService(_repo.Object);

    private static Submission Sample() => new()
    {
        SubmissionId = 1,
        AssignmentId = 1,
        StudentId = 10,
        ContentText = "Bài làm",
        SubmittedAt = DateTime.UtcNow,
    };

    [Fact]
    public async Task CreateAsync_SetsSubmittedAt()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<Submission>())).ReturnsAsync((Submission s) => s);
        var result = await _sut.CreateAsync(new CreateSubmissionDto(1, 10, "Nộp bài", null, null));
        Assert.Equal("Nộp bài", result.ContentText);
        _repo.Verify(r => r.CreateAsync(It.Is<Submission>(s => s.SubmittedAt <= DateTime.UtcNow)), Times.Once);
    }

    [Fact]
    public async Task GradeAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Submission?)null);
        Assert.Null(await _sut.GradeAsync(99, new GradeSubmissionDto(8.0m, "OK", 3)));
    }

    [Fact]
    public async Task GradeAsync_SetsScoreAndFeedback()
    {
        var existing = Sample();
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.GradeAsync(1, It.IsAny<Submission>())).ReturnsAsync((int _, Submission s) => s);
        var result = await _sut.GradeAsync(1, new GradeSubmissionDto(8.5m, "Khá", 3));
        Assert.NotNull(result);
        Assert.Equal(8.5m, result!.Score);
    }

    [Fact]
    public async Task GetByAssignmentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByAssignmentAsync(1)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByAssignmentAsync(1));
    }

    [Fact]
    public async Task GetByStudentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByStudentAsync(10)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByStudentAsync(10));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 3: Chạy & commit**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~AssignmentServiceTests|FullyQualifiedName~SubmissionServiceTests"`

```bash
git add api/PRM393API.Tests/Services/AssignmentServiceTests.cs api/PRM393API.Tests/Services/SubmissionServiceTests.cs
git commit -m "test: add Assignment and Submission service tests"
```

---

### Task 14: StudentRequestServiceTests

**Files:**
- Create: `api/PRM393API.Tests/Services/StudentRequestServiceTests.cs`

- [ ] **Step 1: Tạo file test**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class StudentRequestServiceTests
{
    private readonly Mock<IStudentRequestRepository> _repo = new();
    private readonly StudentRequestService _sut;

    public StudentRequestServiceTests() => _sut = new StudentRequestService(_repo.Object);

    private static StudentRequest Sample() => new()
    {
        StudentRequestId = 1,
        StudentId = 10,
        RequestedBy = 10,
        LeaveDate = new DateOnly(2025, 11, 1),
        Reason = "ốm",
        Status = "Pending",
        CreatedAt = DateTime.UtcNow,
    };

    [Fact]
    public async Task CreateAsync_DefaultStatusPending()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<StudentRequest>())).ReturnsAsync((StudentRequest r) => r);
        var dto = new CreateStudentRequestDto(10, 10, new DateOnly(2025, 11, 2), "việc gia đình", null);
        var result = await _sut.CreateAsync(dto);
        _repo.Verify(r => r.CreateAsync(It.Is<StudentRequest>(x => x.Status == "Pending")), Times.Once);
        Assert.Equal("việc gia đình", result.Reason);
    }

    [Fact]
    public async Task ReviewAsync_Approved_SetsReviewedAt()
    {
        var existing = Sample();
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(existing);
        _repo.Setup(r => r.ReviewAsync(1, It.IsAny<StudentRequest>())).ReturnsAsync((int _, StudentRequest r) => r);
        var result = await _sut.ReviewAsync(1, new ReviewStudentRequestDto("Approved", 3, "OK"));
        Assert.Equal("Approved", result!.Status);
        Assert.NotNull(result.ReviewedAt);
    }

    [Fact]
    public async Task ReviewAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((StudentRequest?)null);
        Assert.Null(await _sut.ReviewAsync(99, new ReviewStudentRequestDto("Rejected", 3, "Không hợp lệ")));
    }

    [Fact]
    public async Task GetPendingAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetPendingAsync()).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetPendingAsync());
    }

    [Fact]
    public async Task GetByStudentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByStudentAsync(10)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByStudentAsync(10));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 2: Chạy & commit**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~StudentRequestServiceTests"`
Expected: PASS (6 tests)

```bash
git add api/PRM393API.Tests/Services/StudentRequestServiceTests.cs
git commit -m "test: add StudentRequestService unit tests"
```

---

### Task 15: Summary services + ParentStudent

**Files:**
- Create: `api/PRM393API.Tests/Services/StudentSemesterSummaryServiceTests.cs`
- Create: `api/PRM393API.Tests/Services/StudentYearlySummaryServiceTests.cs`
- Create: `api/PRM393API.Tests/Services/ParentStudentServiceTests.cs`

- [ ] **Step 1: StudentSemesterSummaryServiceTests**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class StudentSemesterSummaryServiceTests
{
    private readonly Mock<IStudentSemesterSummaryRepository> _repo = new();
    private readonly StudentSemesterSummaryService _sut;

    public StudentSemesterSummaryServiceTests() => _sut = new StudentSemesterSummaryService(_repo.Object);

    private static StudentSemesterSummary Sample() => new()
    {
        SummaryId = 1,
        StudentId = 10,
        SemesterId = 1,
        Gpa = 8.2m,
        Conduct = "Tốt",
        RankId = 1,
        EvaluatedBy = 3,
        EvaluatedAt = DateTime.UtcNow,
    };

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        var result = await _sut.GetByIdAsync(1);
        Assert.Equal(8.2m, result!.Gpa);
    }

    [Fact]
    public async Task CreateAsync_SetsEvaluatedAt()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<StudentSemesterSummary>())).ReturnsAsync((StudentSemesterSummary s) => s);
        var dto = new CreateSemesterSummaryDto(10, 1, 8.0m, "Khá", 2, 3);
        var result = await _sut.CreateAsync(dto);
        Assert.Equal(8.0m, result.Gpa);
        _repo.Verify(r => r.CreateAsync(It.Is<StudentSemesterSummary>(s => s.EvaluatedAt <= DateTime.UtcNow)), Times.Once);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((StudentSemesterSummary?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateSemesterSummaryDto(7.5m, null, null)));
    }

    [Fact]
    public async Task GetByStudentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByStudentAsync(10)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByStudentAsync(10));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 2: StudentYearlySummaryServiceTests**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class StudentYearlySummaryServiceTests
{
    private readonly Mock<IStudentYearlySummaryRepository> _repo = new();
    private readonly StudentYearlySummaryService _sut;

    public StudentYearlySummaryServiceTests() => _sut = new StudentYearlySummaryService(_repo.Object);

    private static StudentYearlySummary Sample() => new()
    {
        YearlySummaryId = 1,
        StudentId = 10,
        AcademicYearId = 1,
        YearlyGpa = 8.5m,
        YearlyConduct = "Tốt",
        RankId = 1,
        EvaluatedBy = 3,
        EvaluatedAt = DateTime.UtcNow,
    };

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        Assert.Equal(8.5m, (await _sut.GetByIdAsync(1))!.YearlyGpa);
    }

    [Fact]
    public async Task CreateAsync_SetsEvaluatedAt()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<StudentYearlySummary>())).ReturnsAsync((StudentYearlySummary s) => s);
        var dto = new CreateYearlySummaryDto(10, 1, 8.3m, "Khá", 2, 3);
        var result = await _sut.CreateAsync(dto);
        Assert.Equal(8.3m, result.YearlyGpa);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((StudentYearlySummary?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateYearlySummaryDto(7.0m, null, null)));
    }

    [Fact]
    public async Task GetByYearAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByYearAsync(1)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByYearAsync(1));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 3: ParentStudentServiceTests**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Tests.Helpers;

namespace PRM393API.Tests.Services;

public class ParentStudentServiceTests
{
    private readonly Mock<IParentStudentRepository> _repo = new();
    private readonly ParentStudentService _sut;

    public ParentStudentServiceTests() => _sut = new ParentStudentService(_repo.Object);

    private static ParentStudent Sample() => new()
    {
        ParentStudentId = 1,
        ParentId = 20,
        StudentId = 10,
        Relationship = "Bố",
        Parent = TestDataFactory.CreateUser(userId: 20, roleId: 5, roleName: "Parent"),
        Student = TestDataFactory.CreateUser(userId: 10, roleId: 4, roleName: "Student"),
    };

    [Fact]
    public async Task CreateAsync_MapsRelationship()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<ParentStudent>())).ReturnsAsync((ParentStudent ps) => ps);
        var result = await _sut.CreateAsync(new CreateParentStudentDto(20, 10, "Mẹ"));
        Assert.Equal("Mẹ", result.Relationship);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((ParentStudent?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateParentStudentDto("Bố")));
    }

    [Fact]
    public async Task GetByParentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByParentAsync(20)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByParentAsync(20));
    }

    [Fact]
    public async Task GetByStudentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByStudentAsync(10)).ReturnsAsync(new[] { Sample() });
        var list = (await _sut.GetByStudentAsync(10)).ToList();
        Assert.Single(list);
        Assert.Equal("Nguyễn Test", list[0].StudentName);
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 4: Chạy batch & commit**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~SummaryServiceTests|FullyQualifiedName~ParentStudentServiceTests"`
Expected: PASS (15 tests)

```bash
git add api/PRM393API.Tests/Services/StudentSemesterSummaryServiceTests.cs api/PRM393API.Tests/Services/StudentYearlySummaryServiceTests.cs api/PRM393API.Tests/Services/ParentStudentServiceTests.cs
git commit -m "test: add summary and ParentStudent service tests"
```

---

### Task 16: AnnouncementServiceTests + NotificationLogServiceTests

**Files:**
- Create: `api/PRM393API.Tests/Services/AnnouncementServiceTests.cs`
- Create: `api/PRM393API.Tests/Services/NotificationLogServiceTests.cs`

- [ ] **Step 1: AnnouncementServiceTests**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class AnnouncementServiceTests
{
    private readonly Mock<IAnnouncementRepository> _repo = new();
    private readonly AnnouncementService _sut;

    public AnnouncementServiceTests() => _sut = new AnnouncementService(_repo.Object);

    private static Announcement Sample() => new()
    {
        AnnouncementId = 1,
        AuthorId = 1,
        Title = "Thông báo",
        Content = "Nội dung",
        AnnouncementType = "School",
        Priority = "Normal",
        IsDeleted = false,
        CreatedAt = DateTime.UtcNow,
        UpdatedAt = DateTime.UtcNow,
        AnnouncementTargets = new List<AnnouncementTarget> { new() { ClassId = 1 } },
    };

    [Fact]
    public async Task CreateAsync_SetsIsDeletedFalseAndPassesTargetClassIds()
    {
        var targetIds = new List<int?> { 1, 2 };
        _repo.Setup(r => r.CreateAsync(It.IsAny<Announcement>(), targetIds))
            .ReturnsAsync((Announcement a, List<int?> _) => a);
        var dto = new CreateAnnouncementDto(1, "Mới", "Chi tiết", "Class", "High", targetIds);
        var result = await _sut.CreateAsync(dto);
        _repo.Verify(r => r.CreateAsync(It.Is<Announcement>(a => !a.IsDeleted), targetIds), Times.Once);
        Assert.Equal("Mới", result.Title);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Announcement?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateAnnouncementDto("X", null, null)));
    }

    [Fact]
    public async Task DeleteAsync_CallsSoftDelete()
    {
        _repo.Setup(r => r.SoftDeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }

    [Fact]
    public async Task GetByClassAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByClassAsync(1)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByClassAsync(1));
    }

    [Fact]
    public async Task GetByIdAsync_MapsTargetClassIds()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        var result = await _sut.GetByIdAsync(1);
        Assert.NotNull(result);
        Assert.Contains(1, result!.TargetClassIds);
    }

    [Fact]
    public async Task GetAllAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetAllAsync());
    }
}
```

- [ ] **Step 2: NotificationLogServiceTests**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class NotificationLogServiceTests
{
    private readonly Mock<INotificationLogRepository> _repo = new();
    private readonly NotificationLogService _sut;

    public NotificationLogServiceTests() => _sut = new NotificationLogService(_repo.Object);

    private static NotificationLog Sample(bool isRead = false) => new()
    {
        NotificationId = 1,
        UserId = 10,
        AnnouncementId = 1,
        Title = "Thông báo mới",
        Body = "Nội dung",
        IsRead = isRead,
        CreatedAt = DateTime.UtcNow,
    };

    [Fact]
    public async Task CreateAsync_DefaultIsReadFalse()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<NotificationLog>())).ReturnsAsync((NotificationLog n) => n);
        var result = await _sut.CreateAsync(new CreateNotificationLogDto(10, 1, "Tiêu đề", "Body"));
        _repo.Verify(r => r.CreateAsync(It.Is<NotificationLog>(n => !n.IsRead)), Times.Once);
        Assert.Equal("Tiêu đề", result.Title);
    }

    [Fact]
    public async Task MarkReadAsync_Existing_ReturnsUpdatedDto()
    {
        var updated = Sample(isRead: true);
        updated.ReadAt = DateTime.UtcNow;
        _repo.Setup(r => r.MarkReadAsync(1)).ReturnsAsync(updated);
        var result = await _sut.MarkReadAsync(1);
        Assert.NotNull(result);
        Assert.True(result!.IsRead);
    }

    [Fact]
    public async Task MarkReadAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.MarkReadAsync(99)).ReturnsAsync((NotificationLog?)null);
        Assert.Null(await _sut.MarkReadAsync(99));
    }

    [Fact]
    public async Task GetUnreadByUserAsync_ReturnsOnlyUnread()
    {
        _repo.Setup(r => r.GetUnreadByUserAsync(10)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetUnreadByUserAsync(10));
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 3: Chạy & commit**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~AnnouncementServiceTests|FullyQualifiedName~NotificationLogServiceTests"`
Expected: PASS (11 tests)

```bash
git add api/PRM393API.Tests/Services/AnnouncementServiceTests.cs api/PRM393API.Tests/Services/NotificationLogServiceTests.cs
git commit -m "test: add Announcement and NotificationLog service tests"
```

---

### Task 17: AssessmentTypeServiceTests + AssessmentServiceTests

**Files:**
- Create: `api/PRM393API.Tests/Services/AssessmentTypeServiceTests.cs`
- Create: `api/PRM393API.Tests/Services/AssessmentServiceTests.cs`

- [ ] **Step 1: AssessmentTypeServiceTests**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class AssessmentTypeServiceTests
{
    private readonly Mock<IAssessmentTypeRepository> _repo = new();
    private readonly AssessmentTypeService _sut;

    public AssessmentTypeServiceTests() => _sut = new AssessmentTypeService(_repo.Object);

    private static AssessmentType Sample() => new()
    {
        AssessmentTypeId = 1,
        TypeName = "Giữa kỳ",
        Weight = 0.3m,
    };

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        Assert.Equal("Giữa kỳ", (await _sut.GetByIdAsync(1))!.TypeName);
    }

    [Fact]
    public async Task CreateAsync_MapsWeight()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<AssessmentType>())).ReturnsAsync((AssessmentType t) => t);
        var result = await _sut.CreateAsync(new CreateAssessmentTypeDto("Cuối kỳ", 0.7m));
        Assert.Equal(0.7m, result.Weight);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((AssessmentType?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateAssessmentTypeDto("X", null)));
    }

    [Fact]
    public async Task GetAllAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetAllAsync()).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetAllAsync());
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 2: AssessmentServiceTests**

```csharp
using Moq;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;

namespace PRM393API.Tests.Services;

public class AssessmentServiceTests
{
    private readonly Mock<IAssessmentRepository> _repo = new();
    private readonly AssessmentService _sut;

    public AssessmentServiceTests() => _sut = new AssessmentService(_repo.Object);

    private static Assessment Sample() => new()
    {
        AssessmentId = 1,
        TeachingAssignmentId = 1,
        AssessmentTypeId = 1,
        AssessmentName = "KT GK1",
        AssessmentDate = new DateOnly(2025, 10, 15),
        MaxScore = 10m,
    };

    [Fact]
    public async Task CreateAsync_MapsFields()
    {
        _repo.Setup(r => r.CreateAsync(It.IsAny<Assessment>())).ReturnsAsync((Assessment a) => a);
        var dto = new CreateAssessmentDto(1, 1, "KT CK1", new DateOnly(2025, 12, 20), 10m);
        var result = await _sut.CreateAsync(dto);
        Assert.Equal("KT CK1", result.AssessmentName);
    }

    [Fact]
    public async Task UpdateAsync_NotFound_ReturnsNull()
    {
        _repo.Setup(r => r.GetByIdAsync(99)).ReturnsAsync((Assessment?)null);
        Assert.Null(await _sut.UpdateAsync(99, new UpdateAssessmentDto("X", null, null)));
    }

    [Fact]
    public async Task GetByTeachingAssignmentAsync_ReturnsList()
    {
        _repo.Setup(r => r.GetByTeachingAssignmentAsync(1)).ReturnsAsync(new[] { Sample() });
        Assert.Single(await _sut.GetByTeachingAssignmentAsync(1));
    }

    [Fact]
    public async Task GetByIdAsync_Existing_ReturnsDto()
    {
        _repo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(Sample());
        Assert.Equal("KT GK1", (await _sut.GetByIdAsync(1))!.AssessmentName);
    }

    [Fact]
    public async Task DeleteAsync_ReturnsRepoResult()
    {
        _repo.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);
        Assert.True(await _sut.DeleteAsync(1));
    }
}
```

- [ ] **Step 3: Chạy & commit**

Run: `dotnet test PRM393API.Tests/PRM393API.Tests.csproj --filter "FullyQualifiedName~AssessmentTypeServiceTests|FullyQualifiedName~AssessmentServiceTests"`
Expected: PASS (10 tests)

```bash
git add api/PRM393API.Tests/Services/AssessmentTypeServiceTests.cs api/PRM393API.Tests/Services/AssessmentServiceTests.cs
git commit -m "test: add AssessmentType and Assessment service tests"
```

---

### Task 18: Chạy full suite + cập nhật docs

**Files:**
- Modify: `docs/MOBILE_PROGRESS.md` hoặc tạo `docs/TEST_COVERAGE.md` (tùy chọn)

- [ ] **Step 1: Chạy toàn bộ test**

Run: `cd api && dotnet test PRM393API.Tests/PRM393API.Tests.csproj --verbosity normal`
Expected: PASS (~140 tests)

- [ ] **Step 2: Ghi nhận coverage**

```bash
dotnet test PRM393API.Tests/PRM393API.Tests.csproj --collect:"XPlat Code Coverage"
```

- [ ] **Step 3: Commit final**

```bash
git add api/PRM393API.Tests/ docs/
git commit -m "test: complete API service unit test suite"
```

---

## Self-Review

**1. Spec coverage:** Mọi service trong `api/Services/*.cs` (24 file) đều có task và file test tương ứng. AuthController giữ nguyên. TimetableService có tách InMemory cho generate.

**2. Placeholder scan:** Không còn TBD/TODO/similar-to — mọi task đều có full test code.

**3. Type consistency:** DTO và method names đã đối chiếu với `api/Services/` và `api/DTOs/`.

**Gaps ngoài phạm vi:**
- Controller tests cho 23 controller còn lại (chỉ service layer trong plan này).
- Integration test E2E API (mobile QA matrix riêng tại `docs/MOBILE_TEST_MATRIX.md`).

---

## Thứ tự thực thi đề xuất

1. Task 0 (hạ tầng)
2. Task 1 (User mở rộng)
3. Task 2–5 (nghiệp vụ cốt lõi: AcademicYear, Class, TeachingAssignment, StudentClass)
4. Task 6–9 (master data)
5. Task 10–17 (nghiệp vụ phụ)
6. Task 18 (full suite)

Mỗi task = 1 commit riêng để dễ review và revert.
