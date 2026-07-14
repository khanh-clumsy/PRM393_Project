using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;
using System.Security.Claims;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class StudentRequestController(IStudentRequestService service) : ControllerBase
{
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var result = await service.GetByIdAsync(id);
        return result is null ? NotFound() : Ok(result);
    }

    [HttpGet("by-student/{studentId:int}")]
    public async Task<IActionResult> GetByStudent(int studentId) =>
        Ok(await service.GetByStudentAsync(studentId));

    [HttpGet("pending")]
    public async Task<IActionResult> GetPending() =>
        Ok(await service.GetPendingAsync());

    [HttpGet("pending/for-teacher")]
    public async Task<IActionResult> GetPendingForTeacher() =>
        Ok(await service.GetPendingForTeacherAsync(GetCurrentUserId()));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateStudentRequestDto dto)
    {
        try
        {
            var role = User.FindFirstValue(ClaimTypes.Role) ?? string.Empty;
            var created = await service.CreateForCurrentUserAsync(dto, GetCurrentUserId(), role);
            return CreatedAtAction(nameof(GetById), new { id = created.StudentRequestId }, created);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
    }

    [HttpPut("{id:int}/review")]
    public async Task<IActionResult> Review(int id, [FromBody] ReviewStudentRequestDto dto)
    {
        try
        {
            var updated = await service.ReviewAsync(id, dto with { ReviewedBy = GetCurrentUserId() });
            return updated is null ? NotFound() : Ok(updated);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await service.DeleteAsync(id);
        return deleted ? NoContent() : NotFound();
    }

    private int GetCurrentUserId() =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? throw new InvalidOperationException("Missing user id claim."));
}
