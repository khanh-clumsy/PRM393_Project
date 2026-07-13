namespace PRM393API.DTOs;

/// <summary>Kỳ (năm học / học kỳ) xác định bởi khoảng StartDate–EndDate.</summary>
public record AcademicPeriodDto(
    int Id,
    string Name,
    DateOnly StartDate,
    DateOnly EndDate);

/// <summary>Ngữ cảnh học thuật tại một ngày tham chiếu.</summary>
public record AcademicContextAtDateDto(
    DateOnly ReferenceDate,
    AcademicPeriodDto? AcademicYear,
    AcademicPeriodDto? Semester);

/// <summary>Phân lớp của học sinh tại ngày tham chiếu (theo năm học chứa ngày đó).</summary>
public record StudentEnrollmentDto(
    int StudentClassId,
    int StudentId,
    string? StudentName,
    string? StudentCode,
    int ClassId,
    string ClassName,
    int AcademicYearId,
    string AcademicYearName);

public record StudentEnrollmentAtDateDto(
    DateOnly ReferenceDate,
    AcademicPeriodDto? AcademicYear,
    AcademicPeriodDto? Semester,
    StudentEnrollmentDto? Enrollment);

public record StudentTimetableAttendanceDto(
    int AttendanceId,
    int TimetableId,
    int StudentId,
    string Status,
    string? Note,
    int RecordedBy,
    DateTime RecordedAt);

/// <summary>TKB tuần của học sinh — mobile chỉ cần bind và hiển thị.</summary>
public record StudentWeeklyTimetableDto(
    int StudentId,
    DateOnly ReferenceDate,
    DateOnly WeekStart,
    DateOnly WeekEnd,
    AcademicPeriodDto? AcademicYear,
    AcademicPeriodDto? Semester,
    StudentEnrollmentDto? Enrollment,
    IReadOnlyList<TimetableSlotDetailDto> Slots,
    IReadOnlyList<StudentTimetableAttendanceDto> Attendance);
