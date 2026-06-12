using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

public partial class AssessmentType
{
    [Key]
    public int AssessmentTypeId { get; set; }

    [StringLength(100)]
    public string TypeName { get; set; } = null!;

    [Column(TypeName = "decimal(5, 2)")]
    public decimal Weight { get; set; }

    [InverseProperty("AssessmentType")]
    public virtual ICollection<Assessment> Assessments { get; set; } = new List<Assessment>();
}
