using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class GradeController(IGradeService service) : ControllerBase
{
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var result = await service.GetByIdAsync(id);
        return result is null ? NotFound() : Ok(result);
    }

    [HttpGet("by-assessment/{assessmentId:int}")]
    public async Task<IActionResult> GetByAssessment(int assessmentId) =>
        Ok(await service.GetByAssessmentAsync(assessmentId));

    [HttpGet("by-student/{studentId:int}")]
    public async Task<IActionResult> GetByStudent(int studentId) =>
        Ok(await service.GetByStudentAsync(studentId));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateGradeDto dto)
    {
        var created = await service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.GradeId }, created);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateGradeDto dto)
    {
        var updated = await service.UpdateAsync(id, dto);
        return updated is null ? NotFound() : Ok(updated);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await service.DeleteAsync(id);
        return deleted ? NoContent() : NotFound();
    }
}
