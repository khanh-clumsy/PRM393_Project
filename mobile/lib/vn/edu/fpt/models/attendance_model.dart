class AttendanceModel {
  final int attendanceId;
  final int timetableId;
  final int studentId;
  final String status; // API có thể trả "P/A/L/E" hoặc "Present/Absent/Late/Excused"
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

  bool get isPresent => ['p', 'present'].contains(status.toLowerCase());
  bool get isAbsent => ['a', 'absent'].contains(status.toLowerCase());
  bool get isLate => ['l', 'late'].contains(status.toLowerCase());
  bool get isExcused => ['e', 'excused'].contains(status.toLowerCase());
}

class AttendanceStatusMapper {
  static String toDisplay(String status) {
    switch (status.toUpperCase()) {
      case 'P':
      case 'PRESENT':
        return 'Có mặt';
      case 'A':
      case 'ABSENT':
        return 'Vắng';
      case 'L':
      case 'LATE':
        return 'Muộn';
      case 'E':
      case 'EXCUSED':
        return 'Có phép';
      default:
        return status;
    }
  }

  static String toApiName(String status) {
    switch (status.toUpperCase()) {
      case 'P':
      case 'PRESENT':
        return 'Present';
      case 'A':
      case 'ABSENT':
        return 'Absent';
      case 'L':
      case 'LATE':
        return 'Late';
      case 'E':
      case 'EXCUSED':
        return 'Excused';
      default:
        return status;
    }
  }

  static String toApiCode(String displayOrCode) {
    final v = displayOrCode.toUpperCase();
    if (v == 'P' || v == 'A' || v == 'L' || v == 'E') return v;
    if (v == 'PRESENT') return 'P';
    if (v == 'ABSENT') return 'A';
    if (v == 'LATE') return 'L';
    if (v == 'EXCUSED') return 'E';
    switch (displayOrCode) {
      case 'Có mặt':
        return 'P';
      case 'Vắng':
        return 'A';
      case 'Muộn':
        return 'L';
      case 'Có phép':
        return 'E';
      default:
        return displayOrCode;
    }
  }
}
