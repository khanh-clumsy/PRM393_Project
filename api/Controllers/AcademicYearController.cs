using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class AcademicYearController(IAcademicYearService service) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await service.GetAllAsync());

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var year = await service.GetByIdAsync(id);
        return year is null ? NotFound() : Ok(year);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateAcademicYearDto dto)
    {
        var created = await service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.AcademicYearId }, created);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateAcademicYearDto dto)
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
