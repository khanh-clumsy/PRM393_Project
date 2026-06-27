namespace PRM393API.DTOs;

public record GradeDto(int GradeId, int AssessmentId, int StudentId, decimal? Score, string? Comment, int EnteredBy, DateTime EnteredAt);
public record CreateGradeDto(int AssessmentId, int StudentId, decimal? Score, string? Comment, int EnteredBy);
public record UpdateGradeDto(decimal? Score, string? Comment);

public record AssessmentGradeDto(int AssessmentId, string AssessmentName, string TypeName, decimal Weight, decimal MaxScore, decimal? Score, string? Comment, DateTime? EnteredAt);
public record SubjectTranscriptDto(int SubjectId, string SubjectName, string SubjectCode, List<AssessmentGradeDto> Grades);
public record AcademicTranscriptDto(int StudentId, int AcademicYearId, List<SubjectTranscriptDto> Subjects);

public record SemesterSubjectTranscriptDto(int SubjectId, string SubjectName, string SubjectCode, decimal? OverallScore, decimal? YearlyAverageScore, bool IsPassed, List<AssessmentGradeDto> Grades);
public record SemesterTranscriptDto(int SemesterId, string SemesterName, decimal? Gpa, string? Conduct, string? RankName, List<SemesterSubjectTranscriptDto> Subjects);
public record YearlyTranscriptDto(int StudentId, int AcademicYearId, decimal? YearlyCumulativeGpa, string? YearlyConduct, List<SemesterTranscriptDto> Semesters);

public record StudentGradeEntryDto(int StudentId, string StudentName, decimal? Score, string? Comment);
public record BulkGradeDto(int AssessmentId, int StudentId, decimal? Score, string? Comment, int EnteredBy);

public record StudentGradeByTypeDto(int StudentId, string StudentName, string Username, string? AvatarUrl, decimal? Score, string? Comment);
public record BulkGradeByTypeDto(int TeachingAssignmentId, int AssessmentTypeId, List<StudentScoreDto> Students);
public record StudentScoreDto(int StudentId, decimal? Score, string? Comment);
