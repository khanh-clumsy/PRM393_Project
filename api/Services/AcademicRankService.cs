using PRM393API.DTOs;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;
using PRM393API.Services.Interfaces;

namespace PRM393API.Services;

public class AcademicRankService(IAcademicRankRepository repo) : IAcademicRankService
{
    public async Task<IEnumerable<AcademicRankDto>> GetAllAsync()
    {
        var list = await repo.GetAllAsync();
        return list.Select(ToDto);
    }

    public async Task<AcademicRankDto?> GetByIdAsync(int id)
    {
        var rank = await repo.GetByIdAsync(id);
        return rank is null ? null : ToDto(rank);
    }

    public async Task<AcademicRankDto> CreateAsync(CreateAcademicRankDto dto)
    {
        var rank = new AcademicRank
        {
            RankName = dto.RankName,
            MinScore = dto.MinScore,
            MaxScore = dto.MaxScore,
        };
        return ToDto(await repo.CreateAsync(rank));
    }

    public async Task<AcademicRankDto?> UpdateAsync(int id, UpdateAcademicRankDto dto)
    {
        var existing = await repo.GetByIdAsync(id);
        if (existing is null) return null;

        existing.RankName = dto.RankName ?? existing.RankName;
        existing.MinScore = dto.MinScore ?? existing.MinScore;
        existing.MaxScore = dto.MaxScore ?? existing.MaxScore;

        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) =>
        await repo.DeleteAsync(id);

    private static AcademicRankDto ToDto(AcademicRank r) =>
        new(r.RankId, r.RankName, r.MinScore, r.MaxScore);
}
