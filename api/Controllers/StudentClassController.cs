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

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateStudentClassDto dto)
    {
        var created = await service.CreateAsync(dto);
        return CreatedAtAction(null, new { id = created.StudentClassId }, created);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await service.DeleteAsync(id);
        return deleted ? NoContent() : NotFound();
    }
}
