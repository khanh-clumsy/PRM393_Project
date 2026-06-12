using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("SubjectCode", Name = "UQ_Subjects_SubjectCode", IsUnique = true)]
public partial class Subject
{
    [Key]
    public int SubjectId { get; set; }

    [StringLength(20)]
    public string SubjectCode { get; set; } = null!;

    [StringLength(100)]
    public string SubjectName { get; set; } = null!;

    public bool IsActive { get; set; }

    [InverseProperty("Subject")]
    public virtual ICollection<TeachingAssignment> TeachingAssignments { get; set; } = new List<TeachingAssignment>();
}
