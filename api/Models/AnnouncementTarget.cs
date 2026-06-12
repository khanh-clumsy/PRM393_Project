using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

public partial class AnnouncementTarget
{
    [Key]
    public int TargetId { get; set; }

    public int AnnouncementId { get; set; }

    public int? ClassId { get; set; }

    [ForeignKey("AnnouncementId")]
    [InverseProperty("AnnouncementTargets")]
    public virtual Announcement Announcement { get; set; } = null!;

    [ForeignKey("ClassId")]
    [InverseProperty("AnnouncementTargets")]
    public virtual Class? Class { get; set; }
}
