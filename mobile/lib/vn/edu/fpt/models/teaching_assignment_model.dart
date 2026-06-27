class TeachingAssignmentModel {
  final int teachingAssignmentId;
  final int teacherId;
  final int classId;
  final int subjectId;
  final int semesterId;
  final String? className;
  final String? subjectName;

  TeachingAssignmentModel({
    required this.teachingAssignmentId,
    required this.teacherId,
    required this.classId,
    required this.subjectId,
    required this.semesterId,
    this.className,
    this.subjectName,
  });

  factory TeachingAssignmentModel.fromJson(Map<String, dynamic> json) {
    return TeachingAssignmentModel(
      teachingAssignmentId: json['teachingAssignmentId'] ?? 0,
      teacherId: json['teacherId'] ?? 0,
      classId: json['classId'] ?? 0,
      subjectId: json['subjectId'] ?? 0,
      semesterId: json['semesterId'] ?? 0,
      className: json['className'],
      subjectName: json['subjectName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teachingAssignmentId': teachingAssignmentId,
      'teacherId': teacherId,
      'classId': classId,
      'subjectId': subjectId,
      'semesterId': semesterId,
      'className': className,
      'subjectName': subjectName,
    };
  }
}
