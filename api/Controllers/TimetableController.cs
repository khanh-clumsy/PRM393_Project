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

    /// <summary>
    /// TKB tuần của học sinh — BE tự resolve lớp theo năm học chứa ngày tham chiếu.
    /// Trả về slots + điểm danh trong tuần + ngữ cảnh năm học/học kỳ/phân lớp.
    /// </summary>
    [HttpGet("weekly/by-student/{studentId:int}")]
    public async Task<IActionResult> GetWeeklyByStudent(int studentId, [FromQuery] DateOnly? date)
    {
        var target = date ?? DateOnly.FromDateTime(DateTime.UtcNow);
        var result = await service.GetWeeklyByStudentAsync(studentId, target);
        return result is null
            ? NotFound(new { message = $"Không tìm thấy phân lớp của học sinh tại ngày {target:yyyy-MM-dd}." })
            : Ok(result);
    }

    [HttpGet("by-assignment/{teachingAssignmentId:int}")]
    public async Task<IActionResult> GetByAssignment(int teachingAssignmentId) =>
        Ok(await service.GetByAssignmentAsync(teachingAssignmentId));

    [HttpGet("by-class/{classId:int}")]
    public async Task<IActionResult> GetByClass(int classId) =>
        Ok(await service.GetByClassAsync(classId));

    [HttpPost("generate/{semesterId:int}")]
    public async Task<IActionResult> Generate(int semesterId, [FromBody] List<TimetableTemplateDto> templates)
    {
        var count = await service.GenerateTimetablesForSemesterAsync(semesterId, templates);
        return Ok(new { Count = count });
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateTimetableDto dto)
    {
        try
        {
            var created = await service.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = created.TimetableId }, created);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
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

    [HttpGet("template/by-class/{classId:int}")]
    public async Task<IActionResult> GetTemplatesByClass(int classId, [FromQuery] int? semesterId) =>
        Ok(await service.GetTemplatesByClassAsync(classId, semesterId));

    [HttpPost("template")]
    public async Task<IActionResult> CreateTemplate([FromBody] CreateTimetableTemplateDto dto)
    {
        try
        {
            var created = await service.CreateTemplateAsync(dto);
            return Ok(created);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("template/{id:int}")]
    public async Task<IActionResult> UpdateTemplate(int id, [FromBody] UpdateTimetableTemplateDto dto)
    {
        try
        {
            var updated = await service.UpdateTemplateAsync(id, dto);
            return updated is null ? NotFound() : Ok(updated);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("template/{id:int}")]
    public async Task<IActionResult> DeleteTemplate(int id)
    {
        var deleted = await service.DeleteTemplateAsync(id);
        return deleted ? NoContent() : NotFound();
    }

    [HttpPost("generate-from-template/{semesterId:int}/{classId:int}")]
    public async Task<IActionResult> GenerateFromTemplate(int semesterId, int classId)
    {
        var count = await service.GenerateFromTemplatesAsync(semesterId, classId);
        return Ok(new { Count = count });
    }

    [HttpPost("clear-generated/{semesterId:int}/{classId:int}")]
    public async Task<IActionResult> ClearGenerated(int semesterId, int classId)
    {
        var count = await service.ClearGeneratedTimetablesAsync(semesterId, classId);
        return Ok(new { Count = count });
    }
}
