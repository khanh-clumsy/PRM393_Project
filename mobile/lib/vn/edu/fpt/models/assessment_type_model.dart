class AssessmentTypeModel {
  final int assessmentTypeId;
  final String typeName;
  final double weight;

  AssessmentTypeModel({
    required this.assessmentTypeId,
    required this.typeName,
    required this.weight,
  });

  factory AssessmentTypeModel.fromJson(Map<String, dynamic> json) {
    return AssessmentTypeModel(
      assessmentTypeId: json['assessmentTypeId'],
      typeName: json['typeName'],
      weight: (json['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assessmentTypeId': assessmentTypeId,
      'typeName': typeName,
      'weight': weight,
    };
  }
}
