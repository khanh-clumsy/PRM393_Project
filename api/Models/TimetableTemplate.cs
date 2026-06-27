using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PRM393API.Models;

public partial class TimetableTemplate
{
    [Key]
    public int TemplateId { get; set; }

    public int TeachingAssignmentId { get; set; }

    public byte DayOfWeek { get; set; }

    public int SlotId { get; set; }

    [StringLength(50)]
    public string? RoomName { get; set; }

    [ForeignKey("SlotId")]
    [InverseProperty("TimetableTemplates")]
    public virtual TimetableSlot Slot { get; set; } = null!;

    [ForeignKey("TeachingAssignmentId")]
    [InverseProperty("TimetableTemplates")]
    public virtual TeachingAssignment TeachingAssignment { get; set; } = null!;
}
