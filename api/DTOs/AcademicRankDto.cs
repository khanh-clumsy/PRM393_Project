namespace PRM393API.DTOs;

public record AcademicRankDto(int RankId, string RankName, decimal MinScore, decimal MaxScore);

public record CreateAcademicRankDto(string RankName, decimal MinScore, decimal MaxScore);

public record UpdateAcademicRankDto(string? RankName, decimal? MinScore, decimal? MaxScore);
