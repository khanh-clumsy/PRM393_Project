class SubjectModel {
  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final bool isActive;

  SubjectModel({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.isActive,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectId: json['subjectId'] as int,
      subjectCode: json['subjectCode'] as String,
      subjectName: json['subjectName'] as String,
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'subjectCode': subjectCode,
      'subjectName': subjectName,
      'isActive': isActive,
    };
  }
}
