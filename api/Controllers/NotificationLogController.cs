using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class NotificationLogController(INotificationLogService service) : ControllerBase
{
    [HttpGet("by-user/{userId:int}")]
    public async Task<IActionResult> GetByUser(int userId) =>
        Ok(await service.GetByUserAsync(userId));

    [HttpGet("by-user/{userId:int}/unread")]
    public async Task<IActionResult> GetUnread(int userId) =>
        Ok(await service.GetUnreadByUserAsync(userId));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateNotificationLogDto dto)
    {
        var created = await service.CreateAsync(dto);
        return StatusCode(201, created);
    }

    [HttpPut("{id:int}/read")]
    public async Task<IActionResult> MarkRead(int id)
    {
        var updated = await service.MarkReadAsync(id);
        return updated is null ? NotFound() : Ok(updated);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await service.DeleteAsync(id);
        return deleted ? NoContent() : NotFound();
    }
}
