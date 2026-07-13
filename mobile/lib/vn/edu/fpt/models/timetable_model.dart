class TimetableModel {
  final int timetableId;
  final int teachingAssignmentId;
  final String date;
  final String slotName;
  final String startTime;
  final String endTime;
  final String? roomName;
  final int subjectId;
  final String subjectName;
  final int teacherId;
  final String teacherName;
  final int classId;
  final String className;
  final int status;
  final String? note;
  final bool isAttendanceTaken;

  TimetableModel({
    required this.timetableId,
    required this.teachingAssignmentId,
    required this.date,
    required this.slotName,
    required this.startTime,
    required this.endTime,
    this.roomName,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.classId,
    required this.className,
    required this.status,
    this.note,
    this.isAttendanceTaken = false,
  });

  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    return TimetableModel(
      timetableId: json['timetableId'] ?? 0,
      teachingAssignmentId: json['teachingAssignmentId'] ?? 0,
      date: json['date'] ?? '',
      slotName: json['slotName'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      roomName: json['roomName'],
      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'] ?? '',
      teacherId: json['teacherId'] ?? 0,
      teacherName: json['teacherName'] ?? '',
      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',
      status: json['status'] ?? 1,
      note: json['note'],
      isAttendanceTaken: json['isAttendanceTaken'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timetableId': timetableId,
      'teachingAssignmentId': teachingAssignmentId,
      'date': date,
      'slotName': slotName,
      'startTime': startTime,
      'endTime': endTime,
      'roomName': roomName,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'classId': classId,
      'className': className,
      'status': status,
      'note': note,
      'isAttendanceTaken': isAttendanceTaken,
    };
  }
}
