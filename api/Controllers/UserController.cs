using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PRM393API.DTOs;
using PRM393API.Services.Interfaces;

namespace PRM393API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class UserController(IUserService service) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await service.GetAllAsync());

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var user = await service.GetByIdAsync(id);
        return user is null ? NotFound() : Ok(user);
    }

    [HttpGet("by-role/{roleId:int}")]
    public async Task<IActionResult> GetByRole(int roleId) =>
        Ok(await service.GetByRoleAsync(roleId));

    [HttpGet("by-department/{departmentId:int}")]
    public async Task<IActionResult> GetByDepartment(int departmentId) =>
        Ok(await service.GetByDepartmentAsync(departmentId));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateUserDto dto)
    {
        var created = await service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateUserDto dto)
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
