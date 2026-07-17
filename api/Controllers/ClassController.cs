using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ClassController(IClassService service) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await service.GetAllAsync());

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var cls = await service.GetByIdAsync(id);
        return cls is null ? NotFound() : Ok(cls);
    }

    [HttpGet("by-year/{academicYearId:int}")]
    public async Task<IActionResult> GetByYear(int academicYearId) =>
        Ok(await service.GetByAcademicYearAsync(academicYearId));

    [HttpGet("by-homeroom/{teacherId:int}")]
    public async Task<IActionResult> GetByHomeroom(int teacherId) =>
        Ok(await service.GetByHomeroomTeacherAsync(teacherId));

    [HttpPost]
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
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await service.DeleteAsync(id);
        return deleted ? NoContent() : NotFound();
    }
}
