using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("ClassId", Name = "IX_TA_ClassId")]
[Index("SemesterId", Name = "IX_TA_SemesterId")]
[Index("TeacherId", Name = "IX_TA_TeacherId")]
[Index("TeacherId", "ClassId", "SubjectId", "SemesterId", Name = "UQ_TeachingAssignments", IsUnique = true)]
public partial class TeachingAssignment
{
    [Key]
    public int TeachingAssignmentId { get; set; }

    public int TeacherId { get; set; }

    public int ClassId { get; set; }

    public int SubjectId { get; set; }

    public int SemesterId { get; set; }

    [InverseProperty("TeachingAssignment")]
    public virtual ICollection<Assessment> Assessments { get; set; } = new List<Assessment>();

    [InverseProperty("TeachingAssignment")]
    public virtual ICollection<Assignment> Assignments { get; set; } = new List<Assignment>();

    [ForeignKey("ClassId")]
    [InverseProperty("TeachingAssignments")]
    public virtual Class Class { get; set; } = null!;

    [ForeignKey("SemesterId")]
    [InverseProperty("TeachingAssignments")]
    public virtual Semester Semester { get; set; } = null!;

    [ForeignKey("SubjectId")]
    [InverseProperty("TeachingAssignments")]
    public virtual Subject Subject { get; set; } = null!;

    [ForeignKey("TeacherId")]
    [InverseProperty("TeachingAssignments")]
    public virtual User Teacher { get; set; } = null!;

    [InverseProperty("TeachingAssignment")]
    public virtual ICollection<Timetable> Timetables { get; set; } = new List<Timetable>();
}
