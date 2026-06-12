using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("AcademicYearId", "SemesterName", Name = "UQ_Semesters_Year_Name", IsUnique = true)]
public partial class Semester
{
    [Key]
    public int SemesterId { get; set; }

    public int AcademicYearId { get; set; }

    [StringLength(50)]
    public string SemesterName { get; set; } = null!;

    public DateOnly StartDate { get; set; }

    public DateOnly EndDate { get; set; }

    [ForeignKey("AcademicYearId")]
    [InverseProperty("Semesters")]
    public virtual AcademicYear AcademicYear { get; set; } = null!;

    [InverseProperty("Semester")]
    public virtual ICollection<StudentSemesterSummary> StudentSemesterSummaries { get; set; } = new List<StudentSemesterSummary>();

    [InverseProperty("Semester")]
    public virtual ICollection<TeachingAssignment> TeachingAssignments { get; set; } = new List<TeachingAssignment>();
}
