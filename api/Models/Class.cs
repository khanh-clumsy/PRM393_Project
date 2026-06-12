using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("ClassName", "AcademicYearId", Name = "UQ_Classes_NameYear", IsUnique = true)]
public partial class Class
{
    [Key]
    public int ClassId { get; set; }

    [StringLength(20)]
    public string ClassName { get; set; } = null!;

    public int AcademicYearId { get; set; }

    public int? HomeroomTeacherId { get; set; }

    [ForeignKey("AcademicYearId")]
    [InverseProperty("Classes")]
    public virtual AcademicYear AcademicYear { get; set; } = null!;

    [InverseProperty("Class")]
    public virtual ICollection<AnnouncementTarget> AnnouncementTargets { get; set; } = new List<AnnouncementTarget>();

    [ForeignKey("HomeroomTeacherId")]
    [InverseProperty("Classes")]
    public virtual User? HomeroomTeacher { get; set; }

    [InverseProperty("Class")]
    public virtual ICollection<StudentClass> StudentClasses { get; set; } = new List<StudentClass>();

    [InverseProperty("Class")]
    public virtual ICollection<TeachingAssignment> TeachingAssignments { get; set; } = new List<TeachingAssignment>();
}
