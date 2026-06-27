class AssessmentModel {
  final int assessmentId;
  final int teachingAssignmentId;
  final int assessmentTypeId;
  final String assessmentName;
  final String assessmentDate;
  final double maxScore;

  AssessmentModel({
    required this.assessmentId,
    required this.teachingAssignmentId,
    required this.assessmentTypeId,
    required this.assessmentName,
    required this.assessmentDate,
    required this.maxScore,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      assessmentId: json['assessmentId'] ?? 0,
      teachingAssignmentId: json['teachingAssignmentId'] ?? 0,
      assessmentTypeId: json['assessmentTypeId'] ?? 0,
      assessmentName: json['assessmentName'] ?? '',
      assessmentDate: json['assessmentDate'] ?? '',
      maxScore: (json['maxScore'] ?? 10).toDouble(),
    );
  }
}
