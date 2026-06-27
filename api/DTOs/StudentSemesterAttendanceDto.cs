using System;
using System.Collections.Generic;

namespace PRM393API.DTOs;

public class SemesterAttendanceSummaryDto
{
    public int TotalPresent { get; set; }
    public int TotalAbsent { get; set; }
    public int TotalLate { get; set; }
    public int TotalExcused { get; set; }
    public List<StudentSubjectAttendanceDto> Subjects { get; set; } = [];
}


public class StudentSubjectAttendanceDto
{
    public int SubjectId { get; set; }
    public string SubjectName { get; set; } = string.Empty;
    public int PresentCount { get; set; }
    public int AbsentCount { get; set; }
    public int LateCount { get; set; }
    public int ExcusedCount { get; set; }
    public int TotalCount { get; set; }
    public List<StudentAttendanceDetailDto> Details { get; set; } = [];
}

public class StudentAttendanceDetailDto
{
    public int TimetableId { get; set; }
    public DateOnly Date { get; set; }
    public string SlotName { get; set; } = string.Empty;
    public string? RoomName { get; set; }
    public string Status { get; set; } = string.Empty; // "Present", "Absent", "Late", "Excused", "Future", "Not Checked"
    public string? Note { get; set; }
}
