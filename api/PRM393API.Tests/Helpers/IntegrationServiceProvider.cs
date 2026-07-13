using PRM393API.Common;
using PRM393API.Models;
using PRM393API.Repositories;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services;
using PRM393API.Services.Interfaces;

namespace PRM393API.Tests.Helpers;

/// <summary>
/// Wire real repositories + services trên InMemory DB cho integration tests.
/// </summary>
internal sealed class IntegrationServiceProvider : IDisposable
{
    public Prm393dbContext Db { get; }
    public IAuthService Auth { get; }
    public ITimetableService Timetable { get; }
    public IAttendanceService Attendance { get; }
    public IAcademicContextService AcademicContext { get; }
    public IParentStudentService ParentStudent { get; }
    public IDepartmentService Department { get; }
    public IUserService User { get; }
    public IGradeService Grade { get; }
    public ITeachingAssignmentService TeachingAssignment { get; }
    public IStudentClassService StudentClass { get; }
    public IAcademicYearService AcademicYear { get; }
    public ISemesterService Semester { get; }
    public ISubjectService Subject { get; }
    public IClassService Class { get; }
    public IAcademicRankService AcademicRank { get; }
    public ITimetableSlotService TimetableSlot { get; }

    public IntegrationServiceProvider(
        IntegrationSeedMode seedMode = IntegrationSeedMode.Full,
        string? dbName = null)
    {
        Db = DbContextTestHelper.CreateInMemoryContext(dbName ?? Guid.NewGuid().ToString());
        if (seedMode == IntegrationSeedMode.Full)
            IntegrationScenarioSeed.Seed(Db);
        else
            IntegrationScenarioSeed.SeedMinimal(Db);

        IAuthRepository authRepo = new AuthRepository(Db);
        IUserRepository userRepo = new UserRepository(Db);
        IDepartmentRepository deptRepo = new DepartmentRepository(Db);
        IAcademicYearRepository yearRepo = new AcademicYearRepository(Db);
        ISemesterRepository semesterRepo = new SemesterRepository(Db);
        IClassRepository classRepo = new ClassRepository(Db);
        IStudentClassRepository studentClassRepo = new StudentClassRepository(Db);
        IAttendanceRepository attendanceRepo = new AttendanceRepository(Db);
        IParentStudentRepository parentStudentRepo = new ParentStudentRepository(Db);
        ITeachingAssignmentRepository taRepo = new TeachingAssignmentRepository(Db);
        ITimetableRepository timetableRepo = new TimetableRepository(Db);
        IGradeRepository gradeRepo = new GradeRepository(Db);
        ISubjectRepository subjectRepo = new SubjectRepository(Db);
        IAcademicRankRepository rankRepo = new AcademicRankRepository(Db);
        ITimetableSlotRepository slotRepo = new TimetableSlotRepository(Db);

        var jwt = TestDataFactory.CreateJwtHelper();
        AcademicContext = new AcademicContextService(Db);
        Auth = new AuthService(authRepo, userRepo, jwt);
        Timetable = new TimetableService(timetableRepo, Db, AcademicContext);
        Attendance = new AttendanceService(attendanceRepo);
        ParentStudent = new ParentStudentService(parentStudentRepo);
        Department = new DepartmentService(deptRepo, userRepo, taRepo);
        User = new UserService(userRepo);
        Grade = new GradeService(gradeRepo);
        TeachingAssignment = new TeachingAssignmentService(taRepo);
        StudentClass = new StudentClassService(studentClassRepo, classRepo, AcademicContext);
        AcademicYear = new AcademicYearService(yearRepo, semesterRepo);
        Semester = new SemesterService(semesterRepo);
        Subject = new SubjectService(subjectRepo);
        Class = new ClassService(classRepo);
        AcademicRank = new AcademicRankService(rankRepo);
        TimetableSlot = new TimetableSlotService(slotRepo);
    }

    public void Dispose() => Db.Dispose();
}
