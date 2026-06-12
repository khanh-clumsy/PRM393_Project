using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("ParentId", "StudentId", Name = "UQ_ParentStudents", IsUnique = true)]
public partial class ParentStudent
{
    [Key]
    public int ParentStudentId { get; set; }

    public int ParentId { get; set; }

    public int StudentId { get; set; }

    [StringLength(50)]
    public string Relationship { get; set; } = null!;

    [ForeignKey("ParentId")]
    [InverseProperty("ParentStudentParents")]
    public virtual User Parent { get; set; } = null!;

    [ForeignKey("StudentId")]
    [InverseProperty("ParentStudentStudents")]
    public virtual User Student { get; set; } = null!;
}
