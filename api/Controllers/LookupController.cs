using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.Services.Interfaces;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class LookupController(
    IAcademicYearService academicYearService,
    ISemesterService semesterService,
    IClassService classService,
    ISubjectService subjectService,
    IUserService userService,
    ITimetableSlotService timetableSlotService) : ControllerBase
{
    [HttpGet("teaching-assignments")]
    public async Task<IActionResult> GetTeachingAssignmentLookups()
    {
        var academicYears = await academicYearService.GetAllAsync();
        var semesters = await semesterService.GetAllAsync();
        var classes = await classService.GetAllAsync();
        var subjects = await subjectService.GetAllAsync();
        var teachers = await userService.GetByRoleAsync(3); // Teacher role ID = 3
        var slots = await timetableSlotService.GetAllAsync();

        return Ok(new
        {
            academicYears,
            semesters,
            classes,
            subjects,
            teachers,
            slots
        });
    }
}
