using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;
using System.Security.Claims;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class AttendanceController(IAttendanceService service) : ControllerBase
{
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        try
        {
            var record = await service.GetByIdForCurrentUserAsync(id, GetCurrentUserId(), GetCurrentRole());
            return record is null ? NotFound() : Ok(record);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
    }

    [HttpGet("by-student/{studentId:int}")]
    public async Task<IActionResult> GetByStudent(int studentId)
    {
        if (User.IsInRole("Teacher"))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Giáo viên chỉ được xem điểm danh theo tiết dạy được phân công." });

        return Ok(await service.GetByStudentAsync(studentId));
    }

    [HttpGet("student/{studentId:int}/semester/{semesterId:int}")]
    public async Task<IActionResult> GetStudentAttendanceSummary(int studentId, int semesterId)
    {
        if (User.IsInRole("Teacher"))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Giáo viên chỉ được xem điểm danh theo tiết dạy được phân công." });

        var summary = await service.GetStudentAttendanceSummaryAsync(studentId, semesterId);
        return Ok(summary);
    }

    [HttpGet("by-timetable/{timetableId:int}")]
    public async Task<IActionResult> GetByTimetable(int timetableId)
    {
        try
        {
            return Ok(await service.GetByTimetableForCurrentUserAsync(timetableId, GetCurrentUserId(), GetCurrentRole()));
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
    }

    [HttpGet("by-student/{studentId:int}/by-date/{date}")]
    public async Task<IActionResult> GetByStudentAndDate(int studentId, DateOnly date)
    {
        if (User.IsInRole("Teacher"))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Giáo viên chỉ được xem điểm danh theo tiết dạy được phân công." });

        return Ok(await service.GetByStudentAndDateAsync(studentId, date));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateAttendanceDto dto)
    {
        try
        {
            var created = await service.CreateForCurrentUserAsync(dto, GetCurrentUserId(), GetCurrentRole());
            return CreatedAtAction(nameof(GetById), new { id = created.AttendanceId }, created);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
    }

    [HttpPost("bulk")]
    public async Task<IActionResult> BulkCreate([FromBody] List<CreateAttendanceDto> dtos)
    {
        try
        {
            var created = await service.BulkCreateForCurrentUserAsync(dtos, GetCurrentUserId(), GetCurrentRole());
            return Ok(created);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
    }

    [HttpPut("bulk")]
    public async Task<IActionResult> BulkUpdate([FromBody] List<BulkUpdateAttendanceDto> dtos)
    {
        try
        {
            var updated = await service.BulkUpdateForCurrentUserAsync(dtos, GetCurrentUserId(), GetCurrentRole());
            return Ok(updated);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateAttendanceDto dto)
    {
        try
        {
            var updated = await service.UpdateForCurrentUserAsync(id, dto, GetCurrentUserId(), GetCurrentRole());
            return updated is null ? NotFound() : Ok(updated);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        try
        {
            var deleted = await service.DeleteForCurrentUserAsync(id, GetCurrentUserId(), GetCurrentRole());
            return deleted ? NoContent() : NotFound();
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
}
