using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("UserId", "AnnouncementId", Name = "UQ_AnnouncementReads", IsUnique = true)]
[Index("UserId", Name = "IX_AR_UserId")]
public partial class AnnouncementRead
{
    [Key]
    public int ReadId { get; set; }

    public int UserId { get; set; }

    public int AnnouncementId { get; set; }

    public DateTime ReadAt { get; set; }

    [ForeignKey("AnnouncementId")]
    [InverseProperty("AnnouncementReads")]
    public virtual Announcement Announcement { get; set; } = null!;

    [ForeignKey("UserId")]
    [InverseProperty("AnnouncementReads")]
    public virtual User User { get; set; } = null!;
}
