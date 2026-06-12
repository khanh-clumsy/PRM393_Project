using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TimetableController(ITimetableService service) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await service.GetAllAsync());

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var t = await service.GetByIdAsync(id);
        return t is null ? NotFound() : Ok(t);
    }

    [HttpGet("{id:int}/detail")]
    public async Task<IActionResult> GetDetail(int id)
    {
        var detail = await service.GetDetailAsync(id);
        return detail is null ? NotFound() : Ok(detail);
    }

    [HttpGet("weekly/by-class/{classId:int}")]
    public async Task<IActionResult> GetWeeklyByClass(int classId, [FromQuery] DateOnly? date)
    {
        var target = date ?? DateOnly.FromDateTime(DateTime.UtcNow);
        return Ok(await service.GetWeeklyByClassAsync(classId, target));
    }

    [HttpGet("weekly/by-teacher/{teacherId:int}")]
    public async Task<IActionResult> GetWeeklyByTeacher(int teacherId, [FromQuery] DateOnly? date)
    {
        var target = date ?? DateOnly.FromDateTime(DateTime.UtcNow);
        return Ok(await service.GetWeeklyByTeacherAsync(teacherId, target));
    }

    [HttpGet("by-assignment/{teachingAssignmentId:int}")]
    public async Task<IActionResult> GetByAssignment(int teachingAssignmentId) =>
        Ok(await service.GetByAssignmentAsync(teachingAssignmentId));

    [HttpGet("by-class/{classId:int}")]
    public async Task<IActionResult> GetByClass(int classId) =>
        Ok(await service.GetByClassAsync(classId));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateTimetableDto dto)
    {
        var created = await service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.TimetableId }, created);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateTimetableDto dto)
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
