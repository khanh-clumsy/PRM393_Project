using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TeachingAssignmentController(ITeachingAssignmentService service) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await service.GetAllAsync());

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var ta = await service.GetByIdAsync(id);
        return ta is null ? NotFound() : Ok(ta);
    }

    [HttpGet("by-teacher/{teacherId:int}")]
    public async Task<IActionResult> GetByTeacher(int teacherId) =>
        Ok(await service.GetByTeacherAsync(teacherId));

    [HttpGet("by-class/{classId:int}")]
    public async Task<IActionResult> GetByClass(int classId) =>
        Ok(await service.GetByClassAsync(classId));

    [HttpGet("by-semester/{semesterId:int}")]
    public async Task<IActionResult> GetBySemester(int semesterId) =>
        Ok(await service.GetBySemesterAsync(semesterId));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateTeachingAssignmentDto dto)
    {
        var created = await service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.TeachingAssignmentId }, created);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await service.DeleteAsync(id);
        return deleted ? NoContent() : NotFound();
    }
}
