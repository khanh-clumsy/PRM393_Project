using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/class")]
[Authorize]
public class ClassSummaryController(IClassSummaryService service) : ControllerBase
{
    private int CurrentUserId =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new InvalidOperationException("Missing user id claim."));

    [HttpGet("{classId:int}/summaries/semester/{semesterId:int}")]
    public async Task<IActionResult> GetSemester(int classId, int semesterId)
    {
        try
        {
            return Ok(await service.GetSemesterBoardAsync(classId, semesterId, CurrentUserId));
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    [HttpPut("{classId:int}/students/{studentId:int}/summaries/semester/{semesterId:int}")]
    public async Task<IActionResult> UpsertSemester(
        int classId, int studentId, int semesterId, [FromBody] UpsertSemesterSummaryDto dto)
    {
        try
        {
            return Ok(await service.UpsertSemesterAsync(classId, studentId, semesterId, CurrentUserId, dto));
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    [HttpGet("{classId:int}/summaries/yearly/{academicYearId:int}")]
    public async Task<IActionResult> GetYearly(int classId, int academicYearId)
    {
        try
        {
            return Ok(await service.GetYearlyBoardAsync(classId, academicYearId, CurrentUserId));
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    [HttpPut("{classId:int}/students/{studentId:int}/summaries/yearly/{academicYearId:int}")]
    public async Task<IActionResult> UpsertYearly(
        int classId, int studentId, int academicYearId, [FromBody] UpsertYearlySummaryDto dto)
    {
        try
        {
            return Ok(await service.UpsertYearlyAsync(classId, studentId, academicYearId, CurrentUserId, dto));
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }
}
