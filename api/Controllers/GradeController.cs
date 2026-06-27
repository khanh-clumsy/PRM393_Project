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

    [HttpGet("transcript/{studentId:int}")]
    public async Task<IActionResult> GetTranscript(int studentId, [FromQuery] int academicYearId)
    {
        return Ok(await service.GetStudentTranscriptAsync(studentId, academicYearId));
    }

    [HttpGet("yearly-transcript/{studentId:int}")]
    public async Task<IActionResult> GetYearlyTranscript(int studentId, [FromQuery] int academicYearId)
    {
        return Ok(await service.GetYearlyTranscriptAsync(studentId, academicYearId));
    }

    [HttpGet("class-grades")]
    public async Task<IActionResult> GetClassGrades([FromQuery] int teachingAssignmentId, [FromQuery] int assessmentId)
    {
        return Ok(await service.GetClassGradesAsync(teachingAssignmentId, assessmentId));
    }

    [HttpPost("bulk")]
    public async Task<IActionResult> SaveBulkGrades([FromBody] List<BulkGradeDto> dto)
    {
        await service.SaveBulkGradesAsync(dto);
        return Ok();
    }

    [HttpGet("class-grades-by-type")]
    public async Task<IActionResult> GetClassGradesByType([FromQuery] int teachingAssignmentId, [FromQuery] int assessmentTypeId)
    {
        return Ok(await service.GetClassGradesByTypeAsync(teachingAssignmentId, assessmentTypeId));
    }

    [HttpPost("bulk-by-type")]
    public async Task<IActionResult> SaveBulkGradesByType([FromBody] BulkGradeByTypeDto dto)
    {
        var teacherIdStr = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (!int.TryParse(teacherIdStr, out int teacherId)) return Unauthorized();

        await service.SaveBulkGradesByTypeAsync(dto, teacherId);
        return Ok();
    }
}
