using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IClassSummaryService
{
    Task<IReadOnlyList<ClassSemesterSummaryRowDto>> GetSemesterBoardAsync(int classId, int semesterId, int teacherId);
    Task<IReadOnlyList<ClassYearlySummaryRowDto>> GetYearlyBoardAsync(int classId, int academicYearId, int teacherId);
    Task<StudentSemesterSummaryDto> UpsertSemesterAsync(int classId, int studentId, int semesterId, int teacherId, UpsertSemesterSummaryDto dto);
    Task<StudentYearlySummaryDto> UpsertYearlyAsync(int classId, int studentId, int academicYearId, int teacherId, UpsertYearlySummaryDto dto);
}
