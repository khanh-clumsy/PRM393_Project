class StudentClassModel {
  final int studentClassId;
  final int studentId;
  final int classId;

  // We can inject the student details in the controller for UI rendering
  String? studentName;
  String? studentCode; // or username

  StudentClassModel({
    required this.studentClassId,
    required this.studentId,
    required this.classId,
    this.studentName,
    this.studentCode,
  });

  factory StudentClassModel.fromJson(Map<String, dynamic> json) {
    return StudentClassModel(
      studentClassId: json['studentClassId'] ?? 0,
      studentId: json['studentId'] ?? 0,
      classId: json['classId'] ?? 0,
      studentName: json['studentName'],
      studentCode: json['studentCode'],
    );
  }
}
