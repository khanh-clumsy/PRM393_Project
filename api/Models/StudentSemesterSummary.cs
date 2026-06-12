using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("SemesterId", Name = "IX_SSS_SemesterId")]
[Index("StudentId", Name = "IX_SSS_StudentId")]
[Index("StudentId", "SemesterId", Name = "UQ_StudentSemesterSummaries", IsUnique = true)]
public partial class StudentSemesterSummary
{
    [Key]
    public int SummaryId { get; set; }

    public int StudentId { get; set; }

    public int SemesterId { get; set; }

    [Column("GPA", TypeName = "decimal(5, 2)")]
    public decimal? Gpa { get; set; }

    [StringLength(50)]
    public string? Conduct { get; set; }

    public int? RankId { get; set; }

    public int? EvaluatedBy { get; set; }

    public DateTime EvaluatedAt { get; set; }

    [ForeignKey("EvaluatedBy")]
    [InverseProperty("StudentSemesterSummaryEvaluatedByNavigations")]
    public virtual User? EvaluatedByNavigation { get; set; }

    [ForeignKey("RankId")]
    [InverseProperty("StudentSemesterSummaries")]
    public virtual AcademicRank? Rank { get; set; }

    [ForeignKey("SemesterId")]
    [InverseProperty("StudentSemesterSummaries")]
    public virtual Semester Semester { get; set; } = null!;

    [ForeignKey("StudentId")]
    [InverseProperty("StudentSemesterSummaryStudents")]
    public virtual User Student { get; set; } = null!;
}
