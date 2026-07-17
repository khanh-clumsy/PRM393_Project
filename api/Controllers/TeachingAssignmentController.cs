using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;
using System.Security.Claims;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TeachingAssignmentController(ITeachingAssignmentService service) : ControllerBase
{
    [HttpGet]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> GetAll() =>
        Ok(await service.GetAllAsync());

    [HttpGet("{id:int}")]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> GetById(int id)
    {
        var ta = await service.GetByIdAsync(id);
        return ta is null ? NotFound() : Ok(ta);
    }

    [HttpGet("by-teacher/{teacherId:int}")]
    public async Task<IActionResult> GetByTeacher(int teacherId)
    {
        if (IsTeacherRequestingAnotherTeacher(teacherId))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Giáo viên chỉ được xem phân công giảng dạy của mình." });

        return Ok(await service.GetByTeacherAsync(teacherId));
    }

    [HttpGet("by-class/{classId:int}")]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> GetByClass(int classId) =>
        Ok(await service.GetByClassAsync(classId));

    [HttpGet("by-semester/{semesterId:int}")]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> GetBySemester(int semesterId) =>
        Ok(await service.GetBySemesterAsync(semesterId));

    [HttpPost]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> Create([FromBody] CreateTeachingAssignmentDto dto)
    {
        try
        {
            var created = await service.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = created.TeachingAssignmentId }, created);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateTeachingAssignmentDto dto)
    {
        try
        {
            var updated = await service.UpdateAsync(id, dto);
            return updated is null ? NotFound() : Ok(updated);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await service.DeleteAsync(id);
        return deleted ? NoContent() : NotFound();
    }

    private bool IsTeacherRequestingAnotherTeacher(int teacherId) =>
        User.IsInRole("Teacher") &&
        int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var currentUserId) &&
        currentUserId != teacherId;
}
