class AcademicYearModel {
  final int academicYearId;
  final String yearName;
  final String startDate; // Backend returns DateOnly as string (YYYY-MM-DD)
  final String endDate;
  final bool isActive;

  AcademicYearModel({
    required this.academicYearId,
    required this.yearName,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      academicYearId: json['academicYearId'] as int,
      yearName: json['yearName'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'academicYearId': academicYearId,
      'yearName': yearName,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
    };
  }
}
