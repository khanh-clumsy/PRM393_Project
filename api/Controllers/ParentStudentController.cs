using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ParentStudentController(IParentStudentService service, IAcademicContextService academicContext) : ControllerBase
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

    [HttpGet("dashboard/{parentId:int}")]
    public async Task<IActionResult> GetDashboard(int parentId, [FromQuery] DateOnly? date, [FromServices] PRM393API.Models.Prm393dbContext db)
    {
        var referenceDate = date ?? DateOnly.FromDateTime(DateTime.UtcNow);
        var parent = await db.Users.FindAsync(parentId);
        if (parent == null) return NotFound("Phụ huynh không tồn tại.");

        var links = await db.ParentStudents
            .Where(ps => ps.ParentId == parentId)
            .Include(ps => ps.Student)
            .ToListAsync();

        var children = new List<object>();
        foreach (var ps in links)
        {
            var enrollment = await academicContext.ResolveStudentEnrollmentAsync(ps.StudentId, referenceDate);
            children.Add(new
            {
                ps.ParentStudentId,
                ps.StudentId,
                StudentName = ps.Student.FullName,
                ps.Relationship,
                ClassId = enrollment?.ClassId,
                ClassName = enrollment?.ClassName,
                AcademicYearId = enrollment?.AcademicYearId,
                AcademicYearName = enrollment?.AcademicYearName,
                EnrollmentResolvedAt = referenceDate,
                AttendanceToday = db.AttendanceRecords
                    .Where(a => a.StudentId == ps.StudentId && a.RecordedAt.Date == referenceDate.ToDateTime(TimeOnly.MinValue).Date)
                    .Select(a => new { a.AttendanceId, a.TimetableId, a.Status, a.Note })
                    .ToList()
            });
        }

        return Ok(new
        {
            ParentId = parent.UserId,
            ParentName = parent.FullName,
            ReferenceDate = referenceDate,
            Children = children
        });
    }
}
