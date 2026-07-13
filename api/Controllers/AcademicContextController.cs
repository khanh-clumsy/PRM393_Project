using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.Services.Interfaces;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/academic-context")]
[Authorize]
public class AcademicContextController(IAcademicContextService service) : ControllerBase
{
    /// <summary>
    /// Xác định năm học và học kỳ tại một ngày (dựa trên StartDate/EndDate, không dùng IsActive).
    /// </summary>
    /// <param name="date">Ngày tham chiếu (YYYY-MM-DD). Mặc định: hôm nay (UTC).</param>
    [HttpGet("at-date")]
    public async Task<IActionResult> GetAtDate([FromQuery] DateOnly? date)
    {
        var target = date ?? DateOnly.FromDateTime(DateTime.UtcNow);
        return Ok(await service.GetContextAtDateAsync(target));
    }
}
