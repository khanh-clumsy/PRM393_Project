using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ParentStudentController(IParentStudentService service) : ControllerBase
{
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var ps = await service.GetByIdAsync(id);
        return ps is null ? NotFound() : Ok(ps);
    }

    [HttpGet("by-parent/{parentId:int}")]
    public async Task<IActionResult> GetByParent(int parentId) =>
        Ok(await service.GetByParentAsync(parentId));

    [HttpGet("by-student/{studentId:int}")]
    public async Task<IActionResult> GetByStudent(int studentId) =>
        Ok(await service.GetByStudentAsync(studentId));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateParentStudentDto dto)
    {
        var created = await service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.ParentStudentId }, created);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateParentStudentDto dto)
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
