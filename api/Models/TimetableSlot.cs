using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

public partial class TimetableSlot
{
    [Key]
    public int SlotId { get; set; }

    [StringLength(20)]
    public string SlotName { get; set; } = null!;

    public TimeOnly StartTime { get; set; }

    public TimeOnly EndTime { get; set; }

    [InverseProperty("Slot")]
    public virtual ICollection<Timetable> Timetables { get; set; } = new List<Timetable>();
}
