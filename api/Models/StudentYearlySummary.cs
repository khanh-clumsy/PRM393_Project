using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("AcademicYearId", Name = "IX_SYS_AcademicYearId")]
[Index("StudentId", Name = "IX_SYS_StudentId")]
[Index("StudentId", "AcademicYearId", Name = "UQ_StudentYearlySummaries", IsUnique = true)]
public partial class StudentYearlySummary
{
    [Key]
    public int YearlySummaryId { get; set; }

    public int StudentId { get; set; }

    public int AcademicYearId { get; set; }

    [Column("YearlyGPA", TypeName = "decimal(5, 2)")]
    public decimal? YearlyGpa { get; set; }

    [StringLength(50)]
    public string? YearlyConduct { get; set; }

    public int? RankId { get; set; }

    public int? EvaluatedBy { get; set; }

    public DateTime EvaluatedAt { get; set; }

    [ForeignKey("AcademicYearId")]
    [InverseProperty("StudentYearlySummaries")]
    public virtual AcademicYear AcademicYear { get; set; } = null!;

    [ForeignKey("EvaluatedBy")]
    [InverseProperty("StudentYearlySummaryEvaluatedByNavigations")]
    public virtual User? EvaluatedByNavigation { get; set; }

    [ForeignKey("RankId")]
    [InverseProperty("StudentYearlySummaries")]
    public virtual AcademicRank? Rank { get; set; }

    [ForeignKey("StudentId")]
    [InverseProperty("StudentYearlySummaryStudents")]
    public virtual User Student { get; set; } = null!;
}
