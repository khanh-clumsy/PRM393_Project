using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("DepartmentName", Name = "UQ_Departments_Name", IsUnique = true)]
public partial class Department
{
    [Key]
    public int DepartmentId { get; set; }

    [StringLength(100)]
    public string DepartmentName { get; set; } = null!;

    [StringLength(200)]
    public string? Description { get; set; }

    [InverseProperty("Department")]
    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
