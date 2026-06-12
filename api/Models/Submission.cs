using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("AssignmentId", Name = "IX_Sub_AssignmentId")]
[Index("StudentId", Name = "IX_Sub_StudentId")]
[Index("AssignmentId", "StudentId", Name = "UQ_Submissions", IsUnique = true)]
public partial class Submission
{
    [Key]
    public int SubmissionId { get; set; }

    public int AssignmentId { get; set; }

    public int StudentId { get; set; }

    public string? ContentText { get; set; }

    [StringLength(500)]
    public string? FileUrl { get; set; }

    [StringLength(500)]
    public string? LinkUrl { get; set; }

    public DateTime SubmittedAt { get; set; }

    [Column(TypeName = "decimal(5, 2)")]
    public decimal? Score { get; set; }

    [StringLength(500)]
    public string? Feedback { get; set; }

    public int? GradedBy { get; set; }

    public DateTime? GradedAt { get; set; }

    [ForeignKey("AssignmentId")]
    [InverseProperty("Submissions")]
    public virtual Assignment Assignment { get; set; } = null!;

    [ForeignKey("GradedBy")]
    [InverseProperty("SubmissionGradedByNavigations")]
    public virtual User? GradedByNavigation { get; set; }

    [ForeignKey("StudentId")]
    [InverseProperty("SubmissionStudents")]
    public virtual User Student { get; set; } = null!;
}
