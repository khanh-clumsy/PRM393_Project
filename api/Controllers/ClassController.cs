using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;
using System.Security.Claims;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ClassController(IClassService service) : ControllerBase
{
    [HttpGet]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> GetAll() =>
        Ok(await service.GetAllAsync());

    [HttpGet("{id:int}")]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> GetById(int id)
    {
        var cls = await service.GetByIdAsync(id);
        return cls is null ? NotFound() : Ok(cls);
    }

    [HttpGet("by-year/{academicYearId:int}")]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> GetByYear(int academicYearId) =>
        Ok(await service.GetByAcademicYearAsync(academicYearId));

    [HttpGet("by-homeroom/{teacherId:int}")]
    public async Task<IActionResult> GetByHomeroom(int teacherId)
    {
        if (IsTeacherRequestingAnotherTeacher(teacherId))
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Giáo viên chỉ được xem lớp chủ nhiệm của mình." });

        return Ok(await service.GetByHomeroomTeacherAsync(teacherId));
    }

    [HttpPost]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> Create([FromBody] CreateClassDto dto)
    {
        try
        {
            var created = await service.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = created.ClassId }, created);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin,HeadOfDept")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateClassDto dto)
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
