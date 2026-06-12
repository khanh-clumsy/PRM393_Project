using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class SubmissionRepository(Prm393dbContext db) : ISubmissionRepository
{
    public async Task<Submission?> GetByIdAsync(int id) =>
        await db.Submissions.FindAsync(id);

    public async Task<IEnumerable<Submission>> GetByAssignmentAsync(int assignmentId) =>
        await db.Submissions.Where(s => s.AssignmentId == assignmentId).ToListAsync();

    public async Task<IEnumerable<Submission>> GetByStudentAsync(int studentId) =>
        await db.Submissions.Where(s => s.StudentId == studentId).ToListAsync();

    public async Task<Submission> CreateAsync(Submission submission)
    {
        db.Submissions.Add(submission);
        await db.SaveChangesAsync();
        return submission;
    }

    public async Task<Submission?> GradeAsync(int id, Submission updated)
    {
        var existing = await db.Submissions.FindAsync(id);
        if (existing is null) return null;

        existing.Score = updated.Score;
        existing.Feedback = updated.Feedback;
        existing.GradedBy = updated.GradedBy;
        existing.GradedAt = updated.GradedAt;
        await db.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var existing = await db.Submissions.FindAsync(id);
        if (existing is null) return false;

        db.Submissions.Remove(existing);
        await db.SaveChangesAsync();
        return true;
    }
}
