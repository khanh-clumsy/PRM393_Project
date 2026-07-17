using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class ClassSummaryService(
    IClassRepository classRepo,
    IStudentClassRepository studentClassRepo,
    IStudentSemesterSummaryRepository semesterSummaryRepo,
    IStudentYearlySummaryRepository yearlySummaryRepo,
    IAcademicRankRepository rankRepo,
    IUserRepository userRepo) : IClassSummaryService
{
    private static readonly HashSet<string> ValidConducts = new(StringComparer.Ordinal)
    {
        "Tốt", "Khá", "Trung Bình", "Yếu",
    };

    public async Task<IReadOnlyList<ClassSemesterSummaryRowDto>> GetSemesterBoardAsync(
        int classId, int semesterId, int teacherId)
    {
        await EnsureHomeroomAsync(classId, teacherId);
        var enrollments = (await studentClassRepo.GetByClassAsync(classId)).ToList();
        var rows = new List<ClassSemesterSummaryRowDto>();

        foreach (var sc in enrollments)
        {
            var user = await userRepo.GetByIdAsync(sc.StudentId);
            var summary = (await semesterSummaryRepo.GetByStudentAsync(sc.StudentId))
                .FirstOrDefault(s => s.SemesterId == semesterId);
            string? rankName = null;
            if (summary?.RankId is int rid)
                rankName = (await rankRepo.GetByIdAsync(rid))?.RankName;

            rows.Add(new ClassSemesterSummaryRowDto(
                sc.StudentId,
                user?.FullName ?? $"#{sc.StudentId}",
                null,
                summary?.SummaryId,
                summary?.Gpa,
                summary?.Conduct,
                summary?.RankId,
                rankName,
                summary is not null && !string.IsNullOrWhiteSpace(summary.Conduct)));
        }

        return rows;
    }

    public async Task<IReadOnlyList<ClassYearlySummaryRowDto>> GetYearlyBoardAsync(
        int classId, int academicYearId, int teacherId)
    {
        await EnsureHomeroomAsync(classId, teacherId);
        var enrollments = (await studentClassRepo.GetByClassAsync(classId)).ToList();
        var rows = new List<ClassYearlySummaryRowDto>();

        foreach (var sc in enrollments)
        {
            var user = await userRepo.GetByIdAsync(sc.StudentId);
            var summary = (await yearlySummaryRepo.GetByStudentAsync(sc.StudentId))
                .FirstOrDefault(s => s.AcademicYearId == academicYearId);
            string? rankName = null;
            if (summary?.RankId is int rid)
                rankName = (await rankRepo.GetByIdAsync(rid))?.RankName;

            rows.Add(new ClassYearlySummaryRowDto(
                sc.StudentId,
                user?.FullName ?? $"#{sc.StudentId}",
                null,
                summary?.YearlySummaryId,
                summary?.YearlyGpa,
                summary?.YearlyConduct,
                summary?.RankId,
                rankName,
                summary is not null && !string.IsNullOrWhiteSpace(summary.YearlyConduct)));
        }

        return rows;
    }

    public async Task<StudentSemesterSummaryDto> UpsertSemesterAsync(
        int classId, int studentId, int semesterId, int teacherId, UpsertSemesterSummaryDto dto)
    {
        await EnsureHomeroomAsync(classId, teacherId);
        await EnsureStudentInClassAsync(classId, studentId);
        if (!ValidConducts.Contains(dto.Conduct))
            throw new ArgumentException("Hạnh kiểm không hợp lệ. Dùng: Tốt, Khá, Trung Bình, Yếu.");

        var rankId = await ResolveRankIdAsync(dto.Gpa, dto.RankId);
        var existing = (await semesterSummaryRepo.GetByStudentAsync(studentId))
            .FirstOrDefault(s => s.SemesterId == semesterId);

        if (existing is null)
        {
            var created = await semesterSummaryRepo.CreateAsync(new StudentSemesterSummary
            {
                StudentId = studentId,
                SemesterId = semesterId,
                Gpa = dto.Gpa,
                Conduct = dto.Conduct,
                RankId = rankId,
                EvaluatedBy = teacherId,
                EvaluatedAt = DateTime.UtcNow,
            });
            return ToSemesterDto(created);
        }

        existing.Conduct = dto.Conduct;
        existing.Gpa = dto.Gpa ?? existing.Gpa;
        existing.RankId = rankId ?? existing.RankId;
        existing.EvaluatedBy = teacherId;
        existing.EvaluatedAt = DateTime.UtcNow;
        var updated = await semesterSummaryRepo.UpdateAsync(existing.SummaryId, existing)
            ?? throw new InvalidOperationException("Không cập nhật được tổng kết học kỳ.");
        return ToSemesterDto(updated);
    }

    public async Task<StudentYearlySummaryDto> UpsertYearlyAsync(
        int classId, int studentId, int academicYearId, int teacherId, UpsertYearlySummaryDto dto)
    {
        await EnsureHomeroomAsync(classId, teacherId);
        await EnsureStudentInClassAsync(classId, studentId);
        if (!ValidConducts.Contains(dto.YearlyConduct))
            throw new ArgumentException("Hạnh kiểm không hợp lệ. Dùng: Tốt, Khá, Trung Bình, Yếu.");

        var rankId = await ResolveRankIdAsync(dto.YearlyGpa, dto.RankId);
        var existing = (await yearlySummaryRepo.GetByStudentAsync(studentId))
            .FirstOrDefault(s => s.AcademicYearId == academicYearId);

        if (existing is null)
        {
            var created = await yearlySummaryRepo.CreateAsync(new StudentYearlySummary
            {
                StudentId = studentId,
                AcademicYearId = academicYearId,
                YearlyGpa = dto.YearlyGpa,
                YearlyConduct = dto.YearlyConduct,
                RankId = rankId,
                EvaluatedBy = teacherId,
                EvaluatedAt = DateTime.UtcNow,
            });
            return ToYearlyDto(created);
        }

        existing.YearlyConduct = dto.YearlyConduct;
        existing.YearlyGpa = dto.YearlyGpa ?? existing.YearlyGpa;
        existing.RankId = rankId ?? existing.RankId;
        existing.EvaluatedBy = teacherId;
        existing.EvaluatedAt = DateTime.UtcNow;
        var updated = await yearlySummaryRepo.UpdateAsync(existing.YearlySummaryId, existing)
            ?? throw new InvalidOperationException("Không cập nhật được tổng kết năm.");
        return ToYearlyDto(updated);
    }

    private async Task EnsureHomeroomAsync(int classId, int teacherId)
    {
        var cls = await classRepo.GetByIdAsync(classId)
            ?? throw new KeyNotFoundException("Không tìm thấy lớp.");
        if (cls.HomeroomTeacherId != teacherId)
            throw new UnauthorizedAccessException("Chỉ giáo viên chủ nhiệm được xem/chốt tổng kết lớp này.");
    }

    private async Task EnsureStudentInClassAsync(int classId, int studentId)
    {
        var inClass = (await studentClassRepo.GetByClassAsync(classId)).Any(sc => sc.StudentId == studentId);
        if (!inClass)
            throw new InvalidOperationException("Học sinh không thuộc lớp này.");
    }

    private async Task<int?> ResolveRankIdAsync(decimal? gpa, int? explicitRankId)
    {
        if (explicitRankId.HasValue) return explicitRankId;
        if (gpa is null) return null;
        var ranks = await rankRepo.GetAllAsync();
        return ranks.FirstOrDefault(r => gpa >= r.MinScore && gpa <= r.MaxScore)?.RankId;
    }

    private static StudentSemesterSummaryDto ToSemesterDto(StudentSemesterSummary s) =>
        new(s.SummaryId, s.StudentId, s.SemesterId, s.Gpa, s.Conduct, s.RankId, s.EvaluatedBy, s.EvaluatedAt);

    private static StudentYearlySummaryDto ToYearlyDto(StudentYearlySummary s) =>
        new(s.YearlySummaryId, s.StudentId, s.AcademicYearId, s.YearlyGpa, s.YearlyConduct, s.RankId, s.EvaluatedBy, s.EvaluatedAt);
}
