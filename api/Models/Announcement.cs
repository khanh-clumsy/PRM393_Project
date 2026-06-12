using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("CreatedAt", Name = "IX_Ann_CreatedAt", AllDescending = true)]
[Index("AnnouncementType", Name = "IX_Ann_Type")]
public partial class Announcement
{
    [Key]
    public int AnnouncementId { get; set; }

    public int AuthorId { get; set; }

    [StringLength(200)]
    public string Title { get; set; } = null!;

    public string Content { get; set; } = null!;

    [StringLength(20)]
    public string AnnouncementType { get; set; } = null!;

    [StringLength(20)]
    public string Priority { get; set; } = null!;

    public bool IsDeleted { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }

    [InverseProperty("Announcement")]
    public virtual ICollection<AnnouncementTarget> AnnouncementTargets { get; set; } = new List<AnnouncementTarget>();

    [ForeignKey("AuthorId")]
    [InverseProperty("Announcements")]
    public virtual User Author { get; set; } = null!;

    [InverseProperty("Announcement")]
    public virtual ICollection<NotificationLog> NotificationLogs { get; set; } = new List<NotificationLog>();
}
