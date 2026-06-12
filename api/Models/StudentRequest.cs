using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("Status", Name = "IX_SR_Status")]
[Index("StudentId", Name = "IX_SR_StudentId")]
public partial class StudentRequest
{
    [Key]
    public int StudentRequestId { get; set; }

    public int StudentId { get; set; }

    public int RequestedBy { get; set; }

    public DateOnly LeaveDate { get; set; }

    [StringLength(500)]
    public string Reason { get; set; } = null!;

    [StringLength(500)]
    public string? AttachmentUrl { get; set; }

    [StringLength(20)]
    public string Status { get; set; } = null!;

    public int? ReviewedBy { get; set; }

    public DateTime? ReviewedAt { get; set; }

    [StringLength(300)]
    public string? ReviewNote { get; set; }

    public DateTime CreatedAt { get; set; }

    [ForeignKey("RequestedBy")]
    [InverseProperty("StudentRequestRequestedByNavigations")]
    public virtual User RequestedByNavigation { get; set; } = null!;

    [ForeignKey("ReviewedBy")]
    [InverseProperty("StudentRequestReviewedByNavigations")]
    public virtual User? ReviewedByNavigation { get; set; }

    [ForeignKey("StudentId")]
    [InverseProperty("StudentRequestStudents")]
    public virtual User Student { get; set; } = null!;
}
