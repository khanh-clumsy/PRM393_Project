using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

public partial class Prm393dbContext : DbContext
{
    public Prm393dbContext()
    {
    }

    public Prm393dbContext(DbContextOptions<Prm393dbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<AcademicRank> AcademicRanks { get; set; }

    public virtual DbSet<AcademicYear> AcademicYears { get; set; }

    public virtual DbSet<Announcement> Announcements { get; set; }

    public virtual DbSet<AnnouncementTarget> AnnouncementTargets { get; set; }

    public virtual DbSet<Assessment> Assessments { get; set; }

    public virtual DbSet<AssessmentType> AssessmentTypes { get; set; }

    public virtual DbSet<AttendanceRecord> AttendanceRecords { get; set; }

    public virtual DbSet<Class> Classes { get; set; }

    public virtual DbSet<Department> Departments { get; set; }

    public virtual DbSet<Grade> Grades { get; set; }

    public virtual DbSet<NotificationLog> NotificationLogs { get; set; }

    public virtual DbSet<ParentStudent> ParentStudents { get; set; }

    public virtual DbSet<RefreshToken> RefreshTokens { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<Semester> Semesters { get; set; }

    public virtual DbSet<StudentClass> StudentClasses { get; set; }

    public virtual DbSet<StudentRequest> StudentRequests { get; set; }

    public virtual DbSet<StudentSemesterSummary> StudentSemesterSummaries { get; set; }

    public virtual DbSet<StudentYearlySummary> StudentYearlySummaries { get; set; }

    public virtual DbSet<Subject> Subjects { get; set; }

    public virtual DbSet<TeachingAssignment> TeachingAssignments { get; set; }

    public virtual DbSet<Timetable> Timetables { get; set; }

    public virtual DbSet<TimetableSlot> TimetableSlots { get; set; }

    public virtual DbSet<TimetableTemplate> TimetableTemplates { get; set; }

    public virtual DbSet<User> Users { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            var config = new Microsoft.Extensions.Configuration.ConfigurationBuilder()
                .SetBasePath(System.IO.Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
                .AddJsonFile("appsettings.Development.json", optional: true)
                .Build();
            optionsBuilder.UseSqlServer(config.GetConnectionString("DefaultConnection"));
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Announcement>(entity =>
        {
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getutcdate())");
            entity.Property(e => e.Priority).HasDefaultValue("normal");
            entity.Property(e => e.UpdatedAt).HasDefaultValueSql("(getutcdate())");

            entity.HasOne(d => d.Author).WithMany(p => p.Announcements)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Ann_Author");
        });

        modelBuilder.Entity<AnnouncementTarget>(entity =>
        {
            entity.HasOne(d => d.Announcement).WithMany(p => p.AnnouncementTargets)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AT_Announcements");

            entity.HasOne(d => d.Class).WithMany(p => p.AnnouncementTargets).HasConstraintName("FK_AT_Classes");
        });

        modelBuilder.Entity<Assessment>(entity =>
        {
            entity.Property(e => e.MaxScore).HasDefaultValue(10.0m);

            entity.HasOne(d => d.AssessmentType).WithMany(p => p.Assessments)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Assess_Type");

            entity.HasOne(d => d.TeachingAssignment).WithMany(p => p.Assessments)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Assess_TA");
        });

        modelBuilder.Entity<AttendanceRecord>(entity =>
        {
            entity.Property(e => e.RecordedAt).HasDefaultValueSql("(getutcdate())");
            entity.Property(e => e.Status).IsFixedLength();

            entity.HasOne(d => d.RecordedByNavigation).WithMany(p => p.AttendanceRecordRecordedByNavigations)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Att_RecordedBy");

            entity.HasOne(d => d.Student).WithMany(p => p.AttendanceRecordStudents)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Att_Students");

            entity.HasOne(d => d.Timetable).WithMany(p => p.AttendanceRecords)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Att_Timetable");
        });

        modelBuilder.Entity<Class>(entity =>
        {
            entity.HasOne(d => d.AcademicYear).WithMany(p => p.Classes)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Classes_AcademicYears");

            entity.HasOne(d => d.HomeroomTeacher).WithMany(p => p.Classes).HasConstraintName("FK_Classes_HomeroomTeacher");
        });

        modelBuilder.Entity<Grade>(entity =>
        {
            entity.Property(e => e.EnteredAt).HasDefaultValueSql("(getutcdate())");

            entity.HasOne(d => d.Assessment).WithMany(p => p.Grades)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Grades_Assessments");

            entity.HasOne(d => d.EnteredByNavigation).WithMany(p => p.GradeEnteredByNavigations)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Grades_EnteredBy");

            entity.HasOne(d => d.Student).WithMany(p => p.GradeStudents)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Grades_Students");
        });

        modelBuilder.Entity<NotificationLog>(entity =>
        {
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getutcdate())");

            entity.HasOne(d => d.Announcement).WithMany(p => p.NotificationLogs).HasConstraintName("FK_NL_Announcements");

            entity.HasOne(d => d.User).WithMany(p => p.NotificationLogs)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_NL_Users");
        });

        modelBuilder.Entity<ParentStudent>(entity =>
        {
            entity.Property(e => e.Relationship).HasDefaultValue("Phụ huynh");

            entity.HasOne(d => d.Parent).WithMany(p => p.ParentStudentParents)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PS_Parents");

            entity.HasOne(d => d.Student).WithMany(p => p.ParentStudentStudents)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PS_Students");
        });

        modelBuilder.Entity<RefreshToken>(entity =>
        {
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getutcdate())");

            entity.HasOne(d => d.User).WithMany(p => p.RefreshTokens)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_RefreshTokens_Users");
        });

        modelBuilder.Entity<Semester>(entity =>
        {
            entity.HasOne(d => d.AcademicYear).WithMany(p => p.Semesters)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Semesters_AcademicYears");
        });

        modelBuilder.Entity<StudentClass>(entity =>
        {
            entity.HasOne(d => d.Class).WithMany(p => p.StudentClasses)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SC_Classes");

            entity.HasOne(d => d.Student).WithMany(p => p.StudentClasses)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SC_Students");
        });

        modelBuilder.Entity<StudentRequest>(entity =>
        {
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getutcdate())");
            entity.Property(e => e.Status).HasDefaultValue("Pending");

            entity.HasOne(d => d.RequestedByNavigation).WithMany(p => p.StudentRequestRequestedByNavigations)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SR_RequestedBy");

            entity.HasOne(d => d.ReviewedByNavigation).WithMany(p => p.StudentRequestReviewedByNavigations).HasConstraintName("FK_SR_ReviewedBy");

            entity.HasOne(d => d.Student).WithMany(p => p.StudentRequestStudents)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SR_Students");
        });

        modelBuilder.Entity<StudentSemesterSummary>(entity =>
        {
            entity.Property(e => e.EvaluatedAt).HasDefaultValueSql("(getutcdate())");

            entity.HasOne(d => d.EvaluatedByNavigation).WithMany(p => p.StudentSemesterSummaryEvaluatedByNavigations).HasConstraintName("FK_SSS_EvaluatedBy");

            entity.HasOne(d => d.Rank).WithMany(p => p.StudentSemesterSummaries).HasConstraintName("FK_SSS_Ranks");

            entity.HasOne(d => d.Semester).WithMany(p => p.StudentSemesterSummaries)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SSS_Semesters");

            entity.HasOne(d => d.Student).WithMany(p => p.StudentSemesterSummaryStudents)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SSS_Students");
        });

        modelBuilder.Entity<StudentYearlySummary>(entity =>
        {
            entity.Property(e => e.EvaluatedAt).HasDefaultValueSql("(getutcdate())");

            entity.HasOne(d => d.AcademicYear).WithMany(p => p.StudentYearlySummaries)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SYS_AcademicYears");

            entity.HasOne(d => d.EvaluatedByNavigation).WithMany(p => p.StudentYearlySummaryEvaluatedByNavigations).HasConstraintName("FK_SYS_EvaluatedBy");

            entity.HasOne(d => d.Rank).WithMany(p => p.StudentYearlySummaries).HasConstraintName("FK_SYS_Ranks");

            entity.HasOne(d => d.Student).WithMany(p => p.StudentYearlySummaryStudents)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SYS_Students");
        });

        modelBuilder.Entity<Subject>(entity =>
        {
            entity.Property(e => e.IsActive).HasDefaultValue(true);
        });

        modelBuilder.Entity<TeachingAssignment>(entity =>
        {
            entity.HasOne(d => d.Class).WithMany(p => p.TeachingAssignments)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TA_Classes");

            entity.HasOne(d => d.Semester).WithMany(p => p.TeachingAssignments)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TA_Semesters");

            entity.HasOne(d => d.Subject).WithMany(p => p.TeachingAssignments)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TA_Subjects");

            entity.HasOne(d => d.Teacher).WithMany(p => p.TeachingAssignments)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TA_Teachers");
        });

        modelBuilder.Entity<Timetable>(entity =>
        {
            entity.HasOne(d => d.Slot).WithMany(p => p.Timetables)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Timetables_Slots");

            entity.HasOne(d => d.TeachingAssignment).WithMany(p => p.Timetables)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Timetables_TA");
        });

        modelBuilder.Entity<TimetableTemplate>(entity =>
        {
            entity.HasOne(d => d.Slot).WithMany(p => p.TimetableTemplates)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Templates_Slots");

            entity.HasOne(d => d.TeachingAssignment).WithMany(p => p.TimetableTemplates)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Templates_TA");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getutcdate())");
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.UpdatedAt).HasDefaultValueSql("(getutcdate())");

            entity.HasOne(d => d.Department).WithMany(p => p.Users).HasConstraintName("FK_Users_Departments");

            entity.HasOne(d => d.Role).WithMany(p => p.Users)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Users_Roles");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
