using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;
using System.Security.Claims;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class GradeController(IGradeService service) : ControllerBase
{
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        if (User.IsInRole("Teacher")) return ForbidTeacherLegacyEndpoint();

        var result = await service.GetByIdAsync(id);
        return result is null ? NotFound() : Ok(result);
    }

    [HttpGet("by-assessment/{assessmentId:int}")]
    public async Task<IActionResult> GetByAssessment(int assessmentId)
    {
        if (User.IsInRole("Teacher")) return ForbidTeacherLegacyEndpoint();

        return Ok(await service.GetByAssessmentAsync(assessmentId));
    }

    [HttpGet("by-student/{studentId:int}")]
    public async Task<IActionResult> GetByStudent(int studentId)
    {
        if (User.IsInRole("Teacher")) return ForbidTeacherLegacyEndpoint();

        return Ok(await service.GetByStudentAsync(studentId));
    }

    [HttpPost]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> Create([FromBody] CreateGradeDto dto)
    {
        var created = await service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.GradeId }, created);
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateGradeDto dto)
    {
        var updated = await service.UpdateAsync(id, dto);
        return updated is null ? NotFound() : Ok(updated);
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await service.DeleteAsync(id);
        return deleted ? NoContent() : NotFound();
    }

    [HttpGet("transcript/{studentId:int}")]
    public async Task<IActionResult> GetTranscript(int studentId, [FromQuery] int academicYearId)
    {
        if (User.IsInRole("Teacher")) return ForbidTeacherLegacyEndpoint();

        return Ok(await service.GetStudentTranscriptAsync(studentId, academicYearId));
    }

    [HttpGet("yearly-transcript/{studentId:int}")]
    public async Task<IActionResult> GetYearlyTranscript(int studentId, [FromQuery] int academicYearId)
    {
        if (User.IsInRole("Teacher")) return ForbidTeacherLegacyEndpoint();

        return Ok(await service.GetYearlyTranscriptAsync(studentId, academicYearId));
    }

    [HttpGet("class-grades")]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> GetClassGrades([FromQuery] int teachingAssignmentId, [FromQuery] int assessmentId)
    {
        return Ok(await service.GetClassGradesAsync(teachingAssignmentId, assessmentId));
    }

    [HttpPost("bulk")]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> SaveBulkGrades([FromBody] List<BulkGradeDto> dto)
    {
        await service.SaveBulkGradesAsync(dto);
        return Ok();
    }

    [HttpGet("class-grades-by-type")]
    public async Task<IActionResult> GetClassGradesByType([FromQuery] int teachingAssignmentId, [FromQuery] int assessmentTypeId)
    {
        try
        {
            return Ok(await service.GetClassGradesByTypeForCurrentUserAsync(
                teachingAssignmentId,
                assessmentTypeId,
                GetCurrentUserId(),
                GetCurrentRole()));
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
    }

    [HttpPost("bulk-by-type")]
    public async Task<IActionResult> SaveBulkGradesByType([FromBody] BulkGradeByTypeDto dto)
    {
        try
        {
            await service.SaveBulkGradesByTypeAsync(dto, GetCurrentUserId());
            return Ok();
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
    }

    private int GetCurrentUserId() =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? throw new InvalidOperationException("Missing user id claim."));

    private string GetCurrentRole() =>
        User.FindFirstValue(ClaimTypes.Role) ?? string.Empty;

    private ObjectResult ForbidTeacherLegacyEndpoint() =>
        StatusCode(StatusCodes.Status403Forbidden, new { message = "Giáo viên chỉ được xem bảng điểm theo lớp và môn được phân công." });
}
