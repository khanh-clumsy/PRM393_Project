using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class AttendanceController(IAttendanceService service) : ControllerBase
{
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var record = await service.GetByIdAsync(id);
        return record is null ? NotFound() : Ok(record);
    }

    [HttpGet("by-student/{studentId:int}")]
    public async Task<IActionResult> GetByStudent(int studentId) =>
        Ok(await service.GetByStudentAsync(studentId));

    [HttpGet("by-timetable/{timetableId:int}")]
    public async Task<IActionResult> GetByTimetable(int timetableId) =>
        Ok(await service.GetByTimetableAsync(timetableId));

    [HttpGet("by-student/{studentId:int}/by-date/{date}")]
    public async Task<IActionResult> GetByStudentAndDate(int studentId, DateOnly date) =>
        Ok(await service.GetByStudentAndDateAsync(studentId, date));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateAttendanceDto dto)
    {
        var created = await service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.AttendanceId }, created);
    }

    [HttpPost("bulk")]
    public async Task<IActionResult> BulkCreate([FromBody] List<CreateAttendanceDto> dtos)
    {
        var created = await service.BulkCreateAsync(dtos);
        return Ok(created);
    }

    [HttpPut("bulk")]
    public async Task<IActionResult> BulkUpdate([FromBody] List<BulkUpdateAttendanceDto> dtos)
    {
        var updated = await service.BulkUpdateAsync(dtos);
        return Ok(updated);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateAttendanceDto dto)
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
