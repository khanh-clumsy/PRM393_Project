using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;
using System.Security.Claims;

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

    [HttpGet("me")]
    public async Task<IActionResult> GetMine() =>
        Ok(await service.GetByUserAsync(GetCurrentUserId()));

    [HttpGet("me/unread-count")]
    public async Task<IActionResult> GetUnreadCount() =>
        Ok(new { count = await service.CountUnreadAsync(GetCurrentUserId()) });

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateNotificationLogDto dto)
    {
        var created = await service.CreateAsync(dto);
        return StatusCode(201, created);
    }

    [HttpPut("{id:int}/read")]
    public async Task<IActionResult> MarkRead(int id)
    {
        var updated = await service.MarkReadAsync(id, GetCurrentUserId());
        return updated is null ? NotFound() : Ok(updated);
    }

    [HttpPut("me/read-all")]
    public async Task<IActionResult> MarkAllRead()
    {
        await service.MarkAllReadAsync(GetCurrentUserId());
        return NoContent();
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await service.DeleteAsync(id);
        return deleted ? NoContent() : NotFound();
    }

    private int GetCurrentUserId() =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? throw new InvalidOperationException("Missing user id claim."));
}
