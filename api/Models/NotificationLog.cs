using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("UserId", "IsRead", Name = "IX_NL_UserId_IsRead")]
public partial class NotificationLog
{
    [Key]
    public int NotificationId { get; set; }

    public int UserId { get; set; }

    public int? AnnouncementId { get; set; }

    [StringLength(200)]
    public string Title { get; set; } = null!;

    [StringLength(500)]
    public string Body { get; set; } = null!;

    public bool IsRead { get; set; }

    public DateTime? ReadAt { get; set; }

    public DateTime CreatedAt { get; set; }

    [ForeignKey("AnnouncementId")]
    [InverseProperty("NotificationLogs")]
    public virtual Announcement? Announcement { get; set; }

    [ForeignKey("UserId")]
    [InverseProperty("NotificationLogs")]
    public virtual User User { get; set; } = null!;
}
