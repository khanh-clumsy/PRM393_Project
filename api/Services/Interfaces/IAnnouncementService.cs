using PRM393API.DTOs;

namespace PRM393API.Services.Interfaces;

public interface IAnnouncementService
{
    Task<IEnumerable<AnnouncementDto>> GetAllAsync();
    Task<AnnouncementDto?> GetByIdAsync(int id);
    Task<IEnumerable<AnnouncementDto>> GetByClassAsync(int classId);
    Task<AnnouncementDto> CreateAsync(CreateAnnouncementDto dto);
    Task<AnnouncementDto?> UpdateAsync(int id, UpdateAnnouncementDto dto);
    Task<bool> DeleteAsync(int id);
}
