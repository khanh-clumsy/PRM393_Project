using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

public partial class AcademicRank
{
    [Key]
    public int RankId { get; set; }

    [StringLength(50)]
    public string RankName { get; set; } = null!;

    [Column(TypeName = "decimal(5, 2)")]
    public decimal MinScore { get; set; }

    [Column(TypeName = "decimal(5, 2)")]
    public decimal MaxScore { get; set; }

    [InverseProperty("Rank")]
    public virtual ICollection<StudentSemesterSummary> StudentSemesterSummaries { get; set; } = new List<StudentSemesterSummary>();

    [InverseProperty("Rank")]
    public virtual ICollection<StudentYearlySummary> StudentYearlySummaries { get; set; } = new List<StudentYearlySummary>();
}
