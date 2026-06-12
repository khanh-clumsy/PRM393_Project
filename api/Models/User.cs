using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("RoleId", Name = "IX_Users_RoleId")]
[Index("Username", Name = "IX_Users_Username")]
[Index("Username", Name = "UQ_Users_Username", IsUnique = true)]
[Index("PhoneNumber", Name = "UQ_Users_PhoneNumber", IsUnique = true)]
public partial class User
{
    [Key]
    public int UserId { get; set; }

    [StringLength(50)]
    public string Username { get; set; } = null!;

    [StringLength(256)]
    public string PasswordHash { get; set; } = null!;

    [StringLength(150)]
    public string FullName { get; set; } = null!;

    public DateOnly? DateOfBirth { get; set; }

    [StringLength(10)]
    public string? Gender { get; set; }

    [StringLength(300)]
    public string? Address { get; set; }

    [StringLength(150)]
    public string? Email { get; set; }

    [StringLength(20)]
    public string? PhoneNumber { get; set; }

    [StringLength(500)]
    public string? AvatarUrl { get; set; }

    public int RoleId { get; set; }

    public int? DepartmentId { get; set; }

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }

    [InverseProperty("Author")]
    public virtual ICollection<Announcement> Announcements { get; set; } = new List<Announcement>();

    [InverseProperty("CreatedByNavigation")]
    public virtual ICollection<Assignment> Assignments { get; set; } = new List<Assignment>();

    [InverseProperty("RecordedByNavigation")]
    public virtual ICollection<AttendanceRecord> AttendanceRecordRecordedByNavigations { get; set; } = new List<AttendanceRecord>();

    [InverseProperty("Student")]
    public virtual ICollection<AttendanceRecord> AttendanceRecordStudents { get; set; } = new List<AttendanceRecord>();

    [InverseProperty("HomeroomTeacher")]
    public virtual ICollection<Class> Classes { get; set; } = new List<Class>();

    [ForeignKey("DepartmentId")]
    [InverseProperty("Users")]
    public virtual Department? Department { get; set; }

    [InverseProperty("EnteredByNavigation")]
    public virtual ICollection<Grade> GradeEnteredByNavigations { get; set; } = new List<Grade>();

    [InverseProperty("Student")]
    public virtual ICollection<Grade> GradeStudents { get; set; } = new List<Grade>();

    [InverseProperty("User")]
    public virtual ICollection<NotificationLog> NotificationLogs { get; set; } = new List<NotificationLog>();

    [InverseProperty("Parent")]
    public virtual ICollection<ParentStudent> ParentStudentParents { get; set; } = new List<ParentStudent>();

    [InverseProperty("Student")]
    public virtual ICollection<ParentStudent> ParentStudentStudents { get; set; } = new List<ParentStudent>();

    [InverseProperty("User")]
    public virtual ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();

    [ForeignKey("RoleId")]
    [InverseProperty("Users")]
    public virtual Role Role { get; set; } = null!;

    [InverseProperty("Student")]
    public virtual ICollection<StudentClass> StudentClasses { get; set; } = new List<StudentClass>();

    [InverseProperty("RequestedByNavigation")]
    public virtual ICollection<StudentRequest> StudentRequestRequestedByNavigations { get; set; } = new List<StudentRequest>();

    [InverseProperty("ReviewedByNavigation")]
    public virtual ICollection<StudentRequest> StudentRequestReviewedByNavigations { get; set; } = new List<StudentRequest>();

    [InverseProperty("Student")]
    public virtual ICollection<StudentRequest> StudentRequestStudents { get; set; } = new List<StudentRequest>();

    [InverseProperty("EvaluatedByNavigation")]
    public virtual ICollection<StudentSemesterSummary> StudentSemesterSummaryEvaluatedByNavigations { get; set; } = new List<StudentSemesterSummary>();

    [InverseProperty("Student")]
    public virtual ICollection<StudentSemesterSummary> StudentSemesterSummaryStudents { get; set; } = new List<StudentSemesterSummary>();

    [InverseProperty("EvaluatedByNavigation")]
    public virtual ICollection<StudentYearlySummary> StudentYearlySummaryEvaluatedByNavigations { get; set; } = new List<StudentYearlySummary>();

    [InverseProperty("Student")]
    public virtual ICollection<StudentYearlySummary> StudentYearlySummaryStudents { get; set; } = new List<StudentYearlySummary>();

    [InverseProperty("GradedByNavigation")]
    public virtual ICollection<Submission> SubmissionGradedByNavigations { get; set; } = new List<Submission>();

    [InverseProperty("Student")]
    public virtual ICollection<Submission> SubmissionStudents { get; set; } = new List<Submission>();

    [InverseProperty("Teacher")]
    public virtual ICollection<TeachingAssignment> TeachingAssignments { get; set; } = new List<TeachingAssignment>();
}
