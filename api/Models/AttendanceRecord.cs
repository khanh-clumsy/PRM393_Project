using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("AttendanceDate", Name = "IX_Att_Date")]
[Index("StudentId", Name = "IX_Att_StudentId")]
[Index("TimetableId", "StudentId", "AttendanceDate", Name = "UQ_AttendanceRecords", IsUnique = true)]
public partial class AttendanceRecord
{
    [Key]
    public int AttendanceId { get; set; }

    public int TimetableId { get; set; }

    public int StudentId { get; set; }

    public DateOnly AttendanceDate { get; set; }

    [StringLength(1)]
    [Unicode(false)]
    public string Status { get; set; } = null!;

    [StringLength(200)]
    public string? Note { get; set; }

    public int RecordedBy { get; set; }

    public DateTime RecordedAt { get; set; }

    [ForeignKey("RecordedBy")]
    [InverseProperty("AttendanceRecordRecordedByNavigations")]
    public virtual User RecordedByNavigation { get; set; } = null!;

    [ForeignKey("StudentId")]
    [InverseProperty("AttendanceRecordStudents")]
    public virtual User Student { get; set; } = null!;

    [ForeignKey("TimetableId")]
    [InverseProperty("AttendanceRecords")]
    public virtual Timetable Timetable { get; set; } = null!;
}
