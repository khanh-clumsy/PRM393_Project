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
        ValidateScores(dto.MinScore, dto.MaxScore);
        await ValidateNoOverlapAsync(dto.MinScore, dto.MaxScore, excludeRankId: null);

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

        var minScore = dto.MinScore ?? existing.MinScore;
        var maxScore = dto.MaxScore ?? existing.MaxScore;
        ValidateScores(minScore, maxScore);
        await ValidateNoOverlapAsync(minScore, maxScore, excludeRankId: id);

        existing.RankName = dto.RankName ?? existing.RankName;
        existing.MinScore = minScore;
        existing.MaxScore = maxScore;

        var updated = await repo.UpdateAsync(id, existing);
        return updated is null ? null : ToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id) =>
        await repo.DeleteAsync(id);

    private static void ValidateScores(decimal minScore, decimal maxScore)
    {
        if (minScore < 0 || maxScore < 0)
        {
            throw new InvalidOperationException("Điểm tối thiểu và điểm tối đa không được âm.");
        }

        if (minScore > maxScore)
        {
            throw new InvalidOperationException("Điểm tối thiểu không được lớn hơn điểm tối đa.");
        }
    }

    private async Task ValidateNoOverlapAsync(decimal minScore, decimal maxScore, int? excludeRankId)
    {
        var all = await repo.GetAllAsync();
        foreach (var other in all)
        {
            if (excludeRankId.HasValue && other.RankId == excludeRankId.Value)
                continue;

            if (RangesOverlap(minScore, maxScore, other.MinScore, other.MaxScore))
            {
                throw new InvalidOperationException(
                    $"Khoảng điểm {minScore}–{maxScore} trùng với xếp loại \"{other.RankName}\" ({other.MinScore}–{other.MaxScore}).");
            }
        }
    }

    private static bool RangesOverlap(decimal min1, decimal max1, decimal min2, decimal max2) =>
        min1 <= max2 && min2 <= max1;

    private static AcademicRankDto ToDto(AcademicRank r) =>
        new(r.RankId, r.RankName, r.MinScore, r.MaxScore);
}
