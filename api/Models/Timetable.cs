using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

public partial class Timetable
{
    [Key]
    public int TimetableId { get; set; }

    public int TeachingAssignmentId { get; set; }

    public DateOnly Date { get; set; }

    public int SlotId { get; set; }

    [StringLength(50)]
    public string? RoomName { get; set; }
    
    public byte Status { get; set; }

    [StringLength(200)]
    public string? Note { get; set; }

    [InverseProperty("Timetable")]
    public virtual ICollection<AttendanceRecord> AttendanceRecords { get; set; } = new List<AttendanceRecord>();

    [ForeignKey("SlotId")]
    [InverseProperty("Timetables")]
    public virtual TimetableSlot Slot { get; set; } = null!;

    [ForeignKey("TeachingAssignmentId")]
    [InverseProperty("Timetables")]
    public virtual TeachingAssignment TeachingAssignment { get; set; } = null!;
}
