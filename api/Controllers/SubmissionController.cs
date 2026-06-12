using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class SubmissionController(ISubmissionService service) : ControllerBase
{
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var result = await service.GetByIdAsync(id);
        return result is null ? NotFound() : Ok(result);
    }

    [HttpGet("by-assignment/{assignmentId:int}")]
    public async Task<IActionResult> GetByAssignment(int assignmentId) =>
        Ok(await service.GetByAssignmentAsync(assignmentId));

    [HttpGet("by-student/{studentId:int}")]
    public async Task<IActionResult> GetByStudent(int studentId) =>
        Ok(await service.GetByStudentAsync(studentId));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateSubmissionDto dto)
    {
        var created = await service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.SubmissionId }, created);
    }

    [HttpPut("{id:int}/grade")]
    public async Task<IActionResult> Grade(int id, [FromBody] GradeSubmissionDto dto)
    {
        var updated = await service.GradeAsync(id, dto);
        return updated is null ? NotFound() : Ok(updated);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await service.DeleteAsync(id);
        return deleted ? NoContent() : NotFound();
    }
}
