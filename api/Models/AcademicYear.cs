using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("YearName", Name = "UQ_AcademicYears_YearName", IsUnique = true)]
public partial class AcademicYear
{
    [Key]
    public int AcademicYearId { get; set; }

    [StringLength(20)]
    public string YearName { get; set; } = null!;

    public DateOnly StartDate { get; set; }

    public DateOnly EndDate { get; set; }

    public bool IsActive { get; set; }

    [InverseProperty("AcademicYear")]
    public virtual ICollection<Class> Classes { get; set; } = new List<Class>();

    [InverseProperty("AcademicYear")]
    public virtual ICollection<Semester> Semesters { get; set; } = new List<Semester>();

    [InverseProperty("AcademicYear")]
    public virtual ICollection<StudentYearlySummary> StudentYearlySummaries { get; set; } = new List<StudentYearlySummary>();
}
