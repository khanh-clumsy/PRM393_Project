using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class StudentClassController(IStudentClassService service) : ControllerBase
{
    [HttpGet("by-class/{classId:int}")]
    public async Task<IActionResult> GetByClass(int classId) =>
        Ok(await service.GetByClassAsync(classId));

    [HttpGet("by-student/{studentId:int}")]
    public async Task<IActionResult> GetByStudent(int studentId) =>
        Ok(await service.GetByStudentAsync(studentId));

    /// <summary>
    /// Phân lớp của học sinh tại ngày tham chiếu.
    /// Năm học/học kỳ được suy ra từ StartDate–EndDate (không dùng IsActive).
    /// </summary>
    [HttpGet("by-student/{studentId:int}/enrollment")]
    public async Task<IActionResult> GetEnrollmentAtDate(int studentId, [FromQuery] DateOnly? date)
    {
        var target = date ?? DateOnly.FromDateTime(DateTime.UtcNow);
        return Ok(await service.GetEnrollmentAtDateAsync(studentId, target));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateStudentClassDto dto)
    {
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
        var deleted = await service.DeleteAsync(id);
        return deleted ? NoContent() : NotFound();
    }
}
