class AttendanceModel {
  final int attendanceId;
  final int timetableId;
  final int studentId;
  final String status; // "Present", "Absent", "Late", "Excused"
  final String? note;
  final int recordedBy;
  final DateTime recordedAt;

  AttendanceModel({
    required this.attendanceId,
    required this.timetableId,
    required this.studentId,
    required this.status,
    this.note,
    required this.recordedBy,
    required this.recordedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      attendanceId: json['attendanceId'] ?? 0,
      timetableId: json['timetableId'] ?? 0,
      studentId: json['studentId'] ?? 0,
      status: json['status'] ?? '',
      note: json['note'],
      recordedBy: json['recordedBy'] ?? 0,
      recordedAt: DateTime.tryParse(json['recordedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendanceId': attendanceId,
      'timetableId': timetableId,
      'studentId': studentId,
      'status': status,
      'note': note,
      'recordedBy': recordedBy,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  bool get isPresent => status.toLowerCase() == 'present';
  bool get isAbsent => status.toLowerCase() == 'absent';
  bool get isLate => status.toLowerCase() == 'late';
  bool get isExcused => status.toLowerCase() == 'excused';
}
