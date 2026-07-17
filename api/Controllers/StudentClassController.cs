using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;
using System.Security.Claims;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class StudentClassController(
    IStudentClassService service,
    ITeachingAssignmentService teachingAssignmentService,
    IClassService classService) : ControllerBase
{
    [HttpGet("by-class/{classId:int}")]
    public async Task<IActionResult> GetByClass(int classId)
    {
        if (User.IsInRole("Teacher") && !await IsTeacherScopedToClassAsync(classId))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Teacher can only view rosters for assigned or homeroom classes." });

        return Ok(await service.GetByClassAsync(classId));
    }

    [HttpGet("by-student/{studentId:int}")]
    public async Task<IActionResult> GetByStudent(int studentId)
    {
        if (User.IsInRole("Teacher"))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Teacher must view rosters by scoped class." });

        return Ok(await service.GetByStudentAsync(studentId));
    }

    /// <summary>
    /// Phân lớp của học sinh tại ngày tham chiếu.
    /// Năm học/học kỳ được suy ra từ StartDate–EndDate (không dùng IsActive).
    /// </summary>
    [HttpGet("by-student/{studentId:int}/enrollment")]
    public async Task<IActionResult> GetEnrollmentAtDate(int studentId, [FromQuery] DateOnly? date)
    {
        if (User.IsInRole("Teacher"))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Teacher must view rosters by scoped class." });

        var target = date ?? DateOnly.FromDateTime(DateTime.UtcNow);
        return Ok(await service.GetEnrollmentAtDateAsync(studentId, target));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateStudentClassDto dto)
    {
        if (User.IsInRole("Teacher"))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Teacher cannot change student class assignments." });

        try
        {
            var created = await service.CreateAsync(dto);
            return CreatedAtAction(null, new { id = created.StudentClassId }, created);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        if (User.IsInRole("Teacher"))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Teacher cannot change student class assignments." });

        var deleted = await service.DeleteAsync(id);
        return deleted ? NoContent() : NotFound();
    }

    private async Task<bool> IsTeacherScopedToClassAsync(int classId)
    {
        var teacherId = GetCurrentUserId();
        var taught = (await teachingAssignmentService.GetByTeacherAsync(teacherId)).Select(ta => ta.ClassId);
        var homeroom = (await classService.GetByHomeroomTeacherAsync(teacherId)).Select(c => c.ClassId);
        return taught.Concat(homeroom).Distinct().Contains(classId);
    }

    private int GetCurrentUserId() =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? throw new InvalidOperationException("Missing user id claim."));
}
