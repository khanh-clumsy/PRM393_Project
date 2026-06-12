using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("DueDate", Name = "IX_Assign_DueDate")]
[Index("IsDeleted", Name = "IX_Assign_IsDeleted")]
public partial class Assignment
{
    [Key]
    public int AssignmentId { get; set; }

    public int TeachingAssignmentId { get; set; }

    [StringLength(200)]
    public string Title { get; set; } = null!;

    public string? Description { get; set; }

    [StringLength(500)]
    public string? AttachmentUrl { get; set; }

    public DateTime DueDate { get; set; }

    public int CreatedBy { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }

    public bool IsDeleted { get; set; }

    [ForeignKey("CreatedBy")]
    [InverseProperty("Assignments")]
    public virtual User CreatedByNavigation { get; set; } = null!;

    [InverseProperty("Assignment")]
    public virtual ICollection<Submission> Submissions { get; set; } = new List<Submission>();

    [ForeignKey("TeachingAssignmentId")]
    [InverseProperty("Assignments")]
    public virtual TeachingAssignment TeachingAssignment { get; set; } = null!;
}
