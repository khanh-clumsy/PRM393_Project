using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

public partial class Assessment
{
    [Key]
    public int AssessmentId { get; set; }

    public int TeachingAssignmentId { get; set; }

    public int AssessmentTypeId { get; set; }

    [StringLength(150)]
    public string AssessmentName { get; set; } = null!;

    public DateOnly AssessmentDate { get; set; }

    [Column(TypeName = "decimal(5, 2)")]
    public decimal MaxScore { get; set; }

    [ForeignKey("AssessmentTypeId")]
    [InverseProperty("Assessments")]
    public virtual AssessmentType AssessmentType { get; set; } = null!;

    [InverseProperty("Assessment")]
    public virtual ICollection<Grade> Grades { get; set; } = new List<Grade>();

    [ForeignKey("TeachingAssignmentId")]
    [InverseProperty("Assessments")]
    public virtual TeachingAssignment TeachingAssignment { get; set; } = null!;
}
