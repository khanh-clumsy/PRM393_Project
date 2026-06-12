using Microsoft.EntityFrameworkCore;
using PRM393API.Models;
using PRM393API.Repositories.Interfaces;

namespace PRM393API.Repositories;

public class AcademicRankRepository(Prm393dbContext db) : IAcademicRankRepository
{
    public async Task<IEnumerable<AcademicRank>> GetAllAsync() =>
        await db.AcademicRanks.ToListAsync();

    public async Task<AcademicRank?> GetByIdAsync(int id) =>
        await db.AcademicRanks.FindAsync(id);

    public async Task<AcademicRank> CreateAsync(AcademicRank rank)
    {
        db.AcademicRanks.Add(rank);
        await db.SaveChangesAsync();
        return rank;
    }

    public async Task<AcademicRank?> UpdateAsync(int id, AcademicRank updated)
    {
        var rank = await db.AcademicRanks.FindAsync(id);
        if (rank is null) return null;

        rank.RankName = updated.RankName;
        rank.MinScore = updated.MinScore;
        rank.MaxScore = updated.MaxScore;
        await db.SaveChangesAsync();
        return rank;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var rank = await db.AcademicRanks.FindAsync(id);
        if (rank is null) return false;

        db.AcademicRanks.Remove(rank);
        await db.SaveChangesAsync();
        return true;
    }
}
