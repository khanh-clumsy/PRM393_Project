class ParentStudentModel {
  final int parentStudentId;
  final int parentId;
  final int studentId;
  final String relationship;

  // Additional details mapped from users
  String? parentName;
  String? parentCode;
  String? studentName;
  String? studentCode;

  ParentStudentModel({
    required this.parentStudentId,
    required this.parentId,
    required this.studentId,
    required this.relationship,
    this.parentName,
    this.parentCode,
    this.studentName,
    this.studentCode,
  });

  factory ParentStudentModel.fromJson(Map<String, dynamic> json) {
    return ParentStudentModel(
      parentStudentId: json['parentStudentId'] ?? 0,
      parentId: json['parentId'] ?? 0,
      studentId: json['studentId'] ?? 0,
      relationship: json['relationship'] ?? '',
      parentName: json['parentName'],
      studentName: json['studentName'],
      parentCode: json['parentCode'],
      studentCode: json['studentCode'],
    );
  }
}
