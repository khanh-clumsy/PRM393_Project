class AcademicRankModel {
  final int rankId;
  final String rankName;
  final double minScore;
  final double maxScore;

  AcademicRankModel({
    required this.rankId,
    required this.rankName,
    required this.minScore,
    required this.maxScore,
  });

  factory AcademicRankModel.fromJson(Map<String, dynamic> json) {
    return AcademicRankModel(
      rankId: json['rankId'] as int,
      rankName: json['rankName'] as String,
      minScore: (json['minScore'] as num).toDouble(),
      maxScore: (json['maxScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rankId': rankId,
      'rankName': rankName,
      'minScore': minScore,
      'maxScore': maxScore,
    };
  }
}
