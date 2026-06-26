class ClassModel {
  final int classId;
  final String className;
  final int academicYearId;
  final int? homeroomTeacherId;

  ClassModel({
    required this.classId,
    required this.className,
    required this.academicYearId,
    this.homeroomTeacherId,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      classId: json['classId'] as int,
      className: json['className'] as String,
      academicYearId: json['academicYearId'] as int,
      homeroomTeacherId: json['homeroomTeacherId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'className': className,
      'academicYearId': academicYearId,
      'homeroomTeacherId': homeroomTeacherId,
    };
  }
}
