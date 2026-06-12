using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("ClassId", Name = "IX_SC_ClassId")]
[Index("StudentId", Name = "IX_SC_StudentId")]
[Index("StudentId", "ClassId", Name = "UQ_StudentClasses", IsUnique = true)]
public partial class StudentClass
{
    [Key]
    public int StudentClassId { get; set; }

    public int StudentId { get; set; }

    public int ClassId { get; set; }

    [ForeignKey("ClassId")]
    [InverseProperty("StudentClasses")]
    public virtual Class Class { get; set; } = null!;

    [ForeignKey("StudentId")]
    [InverseProperty("StudentClasses")]
    public virtual User Student { get; set; } = null!;
}
