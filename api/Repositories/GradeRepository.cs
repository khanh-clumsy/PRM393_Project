using Microsoft.EntityFrameworkCore;
using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class GradeRepository(Prm393dbContext db) : IGradeRepository
{
    public async Task<Grade?> GetByIdAsync(int id) =>
        await db.Grades.FindAsync(id);

    public async Task<IEnumerable<Grade>> GetByAssessmentAsync(int assessmentId) =>
        await db.Grades.Where(g => g.AssessmentId == assessmentId).ToListAsync();

    public async Task<IEnumerable<Grade>> GetByStudentAsync(int studentId) =>
        await db.Grades.Where(g => g.StudentId == studentId).ToListAsync();

    public async Task<Grade> CreateAsync(Grade grade)
    {
        db.Grades.Add(grade);
        await db.SaveChangesAsync();
        return grade;
    }

    public async Task<Grade?> UpdateAsync(int id, Grade updated)
    {
        var existing = await db.Grades.FindAsync(id);
        if (existing is null) return null;

        existing.Score = updated.Score;
        existing.Comment = updated.Comment;
        await db.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var existing = await db.Grades.FindAsync(id);
        if (existing is null) return false;

        db.Grades.Remove(existing);
        await db.SaveChangesAsync();
        return true;
    }

    public async Task<AcademicTranscriptDto> GetStudentTranscriptAsync(int studentId, int academicYearId)
    {
        var data = await db.TeachingAssignments
            .Include(ta => ta.Subject)
            .Include(ta => ta.Semester)
            .Include(ta => ta.Assessments)
                .ThenInclude(a => a.AssessmentType)
            .Include(ta => ta.Assessments)
                .ThenInclude(a => a.Grades.Where(g => g.StudentId == studentId))
            .Where(ta => ta.Semester.AcademicYearId == academicYearId && 
                         db.StudentClasses.Any(sc => sc.StudentId == studentId && sc.ClassId == ta.ClassId))
            .ToListAsync();

        var subjects = new List<SubjectTranscriptDto>();

        foreach (var ta in data)
        {
            var existingSub = subjects.FirstOrDefault(s => s.SubjectId == ta.SubjectId);
            if (existingSub == null)
            {
                existingSub = new SubjectTranscriptDto(
                    ta.SubjectId,
                    ta.Subject.SubjectName,
                    ta.Subject.SubjectCode,
                    new List<AssessmentGradeDto>()
                );
                subjects.Add(existingSub);
            }

            foreach (var a in ta.Assessments)
            {
                var g = a.Grades.FirstOrDefault();
                existingSub.Grades.Add(new AssessmentGradeDto(
                    a.AssessmentId,
                    a.AssessmentName,
                    a.AssessmentType.TypeName,
                    a.AssessmentType.Weight,
                    a.MaxScore,
                    g?.Score,
                    g?.Comment,
                    g?.EnteredAt
                ));
            }
        }

        return new AcademicTranscriptDto(studentId, academicYearId, subjects);
    }

    public async Task<YearlyTranscriptDto> GetYearlyTranscriptAsync(int studentId, int academicYearId)
    {
        var allSemesters = await db.Semesters
            .Where(s => s.AcademicYearId == academicYearId)
            .OrderBy(s => s.StartDate)
            .ToListAsync();

        var data = await db.TeachingAssignments
            .Include(ta => ta.Subject)
            .Include(ta => ta.Semester)
            .Include(ta => ta.Assessments)
                .ThenInclude(a => a.AssessmentType)
            .Include(ta => ta.Assessments)
                .ThenInclude(a => a.Grades.Where(g => g.StudentId == studentId))
            .Where(ta => ta.Semester.AcademicYearId == academicYearId &&
                         db.StudentClasses.Any(sc => sc.StudentId == studentId && sc.ClassId == ta.ClassId))
            .ToListAsync();

        var assignmentsBySemester = data
            .GroupBy(ta => ta.SemesterId)
            .ToDictionary(g => g.Key, g => g.ToList());

        var semesters = new List<SemesterTranscriptDto>();

        foreach (var semester in allSemesters)
        {
            var semesterSubjects = assignmentsBySemester.TryGetValue(semester.SemesterId, out var assignments)
                ? BuildSemesterSubjects(assignments)
                : [];

            var semesterSummary = await db.StudentSemesterSummaries
                .Include(s => s.Rank)
                .FirstOrDefaultAsync(s => s.StudentId == studentId && s.SemesterId == semester.SemesterId);

            semesters.Add(new SemesterTranscriptDto(
                semester.SemesterId,
                semester.SemesterName,
                semesterSummary?.Gpa,
                semesterSummary?.Conduct,
                semesterSummary?.Rank?.RankName,
                semesterSubjects
            ));
        }

        // Calculate Yearly Average for each subject: (Sem1 + Sem2*2) / 3
        // ToList() trước — tránh "Collection was modified" khi cập nhật Subjects trong vòng lặp.
        var allSubjectIds = semesters
            .SelectMany(s => s.Subjects)
            .Select(s => s.SubjectId)
            .Distinct()
            .ToList();

        foreach (var subjectId in allSubjectIds)
        {
            var ordered = semesters.OrderBy(s => s.SemesterName).ToList();
            var sem1Subject = ordered.FirstOrDefault()?.Subjects.FirstOrDefault(s => s.SubjectId == subjectId);
            var sem2Subject = ordered.LastOrDefault()?.Subjects.FirstOrDefault(s => s.SubjectId == subjectId);

            if (sem1Subject?.OverallScore != null && sem2Subject?.OverallScore != null)
            {
                var yearlyAvg = Math.Round((sem1Subject.OverallScore.Value + sem2Subject.OverallScore.Value * 2) / 3, 1);

                foreach (var sem in semesters)
                {
                    var index = sem.Subjects.FindIndex(s => s.SubjectId == subjectId);
                    if (index >= 0)
                    {
                        sem.Subjects[index] = sem.Subjects[index] with { YearlyAverageScore = yearlyAvg };
                    }
                }
            }
        }

        var yearlySummary = await db.StudentYearlySummaries
            .FirstOrDefaultAsync(s => s.StudentId == studentId && s.AcademicYearId == academicYearId);

        return new YearlyTranscriptDto(
            studentId,
            academicYearId,
            yearlySummary?.YearlyGpa,
            yearlySummary?.YearlyConduct,
            semesters);
    }

    private static List<SemesterSubjectTranscriptDto> BuildSemesterSubjects(IEnumerable<TeachingAssignment> assignments)
    {
        var semesterSubjects = new List<SemesterSubjectTranscriptDto>();

        foreach (var ta in assignments)
        {
            var grades = new List<AssessmentGradeDto>();
            decimal totalWeight = 0;
            decimal totalScore = 0;

            foreach (var a in ta.Assessments)
            {
                var g = a.Grades.FirstOrDefault();
                grades.Add(new AssessmentGradeDto(
                    a.AssessmentId,
                    a.AssessmentName,
                    a.AssessmentType.TypeName,
                    a.AssessmentType.Weight,
                    a.MaxScore,
                    g?.Score,
                    g?.Comment,
                    g?.EnteredAt
                ));

                if (g?.Score != null)
                {
                    totalWeight += a.AssessmentType.Weight;
                    totalScore += g.Score.Value * a.AssessmentType.Weight;
                }
            }

            decimal? overallScore = totalWeight > 0 ? Math.Round(totalScore / totalWeight, 1) : null;
            bool isPassed = overallScore >= 5.0m;

            semesterSubjects.Add(new SemesterSubjectTranscriptDto(
                ta.SubjectId,
                ta.Subject.SubjectName,
                ta.Subject.SubjectCode,
                overallScore,
                null,
                isPassed,
                grades
            ));
        }

        return semesterSubjects;
    }

    public async Task<IEnumerable<StudentGradeEntryDto>> GetClassGradesAsync(int teachingAssignmentId, int assessmentId)
    {
        var ta = await db.TeachingAssignments
            .Include(t => t.Class)
            .FirstOrDefaultAsync(t => t.TeachingAssignmentId == teachingAssignmentId);

        if (ta == null) return new List<StudentGradeEntryDto>();

        var students = await db.StudentClasses
            .Include(sc => sc.Student)
            .Where(sc => sc.ClassId == ta.ClassId)
            .ToListAsync();

        var grades = await db.Grades
            .Where(g => g.AssessmentId == assessmentId)
            .ToListAsync();

        var result = new List<StudentGradeEntryDto>();
        foreach (var sc in students)
        {
            var g = grades.FirstOrDefault(x => x.StudentId == sc.StudentId);
            result.Add(new StudentGradeEntryDto(
                sc.StudentId,
                sc.Student.FullName,
                g?.Score,
                g?.Comment
            ));
        }

        return result;
    }

    public async Task SaveBulkGradesAsync(List<BulkGradeDto> grades)
    {
        foreach (var dto in grades)
        {
            var existing = await db.Grades.FirstOrDefaultAsync(g => g.AssessmentId == dto.AssessmentId && g.StudentId == dto.StudentId);
            if (existing != null)
            {
                if (dto.Score == null && dto.Comment == null)
                {
                    // If no score and comment passed, might mean to delete or ignore. 
                    // Let's assume ignore for bulk updates unless explicitly asked to clear.
                    // If they send Score = null, we update to null
                    existing.Score = null;
                    existing.Comment = dto.Comment;
                }
                else
                {
                    existing.Score = dto.Score;
                    existing.Comment = dto.Comment;
                }
            }
            else
            {
                if (dto.Score != null || dto.Comment != null)
                {
                    db.Grades.Add(new Grade
                    {
                        AssessmentId = dto.AssessmentId,
                        StudentId = dto.StudentId,
                        Score = dto.Score,
                        Comment = dto.Comment,
                        EnteredBy = dto.EnteredBy,
                        EnteredAt = DateTime.UtcNow
                    });
                }
            }
        }
        await db.SaveChangesAsync();
    }

    public async Task<IEnumerable<StudentGradeByTypeDto>> GetClassGradesByTypeAsync(int teachingAssignmentId, int assessmentTypeId)
    {
        var ta = await db.TeachingAssignments
            .Include(t => t.Class)
            .FirstOrDefaultAsync(t => t.TeachingAssignmentId == teachingAssignmentId);

        if (ta == null) return new List<StudentGradeByTypeDto>();

        var students = await db.StudentClasses
            .Include(sc => sc.Student)
            .Where(sc => sc.ClassId == ta.ClassId)
            .ToListAsync();

        var assessment = await db.Assessments
            .Include(a => a.Grades)
            .FirstOrDefaultAsync(a => a.TeachingAssignmentId == teachingAssignmentId && a.AssessmentTypeId == assessmentTypeId);

        var result = new List<StudentGradeByTypeDto>();
        foreach (var sc in students)
        {
            var g = assessment?.Grades.FirstOrDefault(x => x.StudentId == sc.StudentId);
            result.Add(new StudentGradeByTypeDto(
                sc.StudentId,
                sc.Student.FullName,
                sc.Student.Username,
                sc.Student.AvatarUrl,
                g?.Score,
                g?.Comment
            ));
        }

        return result.OrderBy(s => s.StudentName).ToList();
    }

    public async Task SaveBulkGradesByTypeAsync(BulkGradeByTypeDto dto, int teacherId)
    {
        var assessment = await db.Assessments
            .FirstOrDefaultAsync(a => a.TeachingAssignmentId == dto.TeachingAssignmentId && a.AssessmentTypeId == dto.AssessmentTypeId);

        if (assessment == null)
        {
            var assessmentType = await db.AssessmentTypes.FindAsync(dto.AssessmentTypeId);
            if (assessmentType == null) throw new Exception("Assessment Type not found");

            assessment = new Assessment
            {
                TeachingAssignmentId = dto.TeachingAssignmentId,
                AssessmentTypeId = dto.AssessmentTypeId,
                AssessmentName = assessmentType.TypeName, // Default name based on type
                AssessmentDate = DateOnly.FromDateTime(DateTime.UtcNow),
                MaxScore = 10.0M
            };
            db.Assessments.Add(assessment);
            await db.SaveChangesAsync(); // To get AssessmentId
        }

        foreach (var s in dto.Students)
        {
            var existingGrade = await db.Grades
                .FirstOrDefaultAsync(g => g.AssessmentId == assessment.AssessmentId && g.StudentId == s.StudentId);

            if (existingGrade != null)
            {
                if (s.Score == null && s.Comment == null)
                {
                    existingGrade.Score = null;
                    existingGrade.Comment = null;
                }
                else
                {
                    existingGrade.Score = s.Score;
                    existingGrade.Comment = s.Comment;
                    existingGrade.EnteredBy = teacherId; // Update person who changed it
                    existingGrade.EnteredAt = DateTime.UtcNow;
                }
            }
            else
            {
                if (s.Score != null || s.Comment != null)
                {
                    db.Grades.Add(new Grade
                    {
                        AssessmentId = assessment.AssessmentId,
                        StudentId = s.StudentId,
                        Score = s.Score,
                        Comment = s.Comment,
                        EnteredBy = teacherId,
                        EnteredAt = DateTime.UtcNow
                    });
                }
            }
        }

        await db.SaveChangesAsync();
    }
}
