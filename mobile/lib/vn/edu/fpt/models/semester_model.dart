class SemesterModel {
  final int semesterId;
  final int academicYearId;
  final String semesterName;
  final String startDate; // DateOnly from C#
  final String endDate;

  SemesterModel({
    required this.semesterId,
    required this.academicYearId,
    required this.semesterName,
    required this.startDate,
    required this.endDate,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      semesterId: json['semesterId'] as int,
      academicYearId: json['academicYearId'] as int,
      semesterName: json['semesterName'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'semesterId': semesterId,
      'academicYearId': academicYearId,
      'semesterName': semesterName,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
