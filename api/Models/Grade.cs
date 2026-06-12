using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("AssessmentId", Name = "IX_Grades_AssessmentId")]
[Index("StudentId", Name = "IX_Grades_StudentId")]
[Index("AssessmentId", "StudentId", Name = "UQ_Grades", IsUnique = true)]
public partial class Grade
{
    [Key]
    public int GradeId { get; set; }

    public int AssessmentId { get; set; }

    public int StudentId { get; set; }

    [Column(TypeName = "decimal(5, 2)")]
    public decimal? Score { get; set; }

    [StringLength(200)]
    public string? Comment { get; set; }

    public int EnteredBy { get; set; }

    public DateTime EnteredAt { get; set; }

    [ForeignKey("AssessmentId")]
    [InverseProperty("Grades")]
    public virtual Assessment Assessment { get; set; } = null!;

    [ForeignKey("EnteredBy")]
    [InverseProperty("GradeEnteredByNavigations")]
    public virtual User EnteredByNavigation { get; set; } = null!;

    [ForeignKey("StudentId")]
    [InverseProperty("GradeStudents")]
    public virtual User Student { get; set; } = null!;
}
