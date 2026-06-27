class TimetableTemplateModel {
  final int templateId;
  final int teachingAssignmentId;
  final int dayOfWeek;
  final int slotId;
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
  final int semesterId;

  TimetableTemplateModel({
    required this.templateId,
    required this.teachingAssignmentId,
    required this.dayOfWeek,
    required this.slotId,
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
    required this.semesterId,
  });

  factory TimetableTemplateModel.fromJson(Map<String, dynamic> json) {
    return TimetableTemplateModel(
      templateId: json['templateId'] ?? 0,
      teachingAssignmentId: json['teachingAssignmentId'] ?? 0,
      dayOfWeek: json['dayOfWeek'] ?? 2,
      slotId: json['slotId'] ?? 0,
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
      semesterId: json['semesterId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'teachingAssignmentId': teachingAssignmentId,
      'dayOfWeek': dayOfWeek,
      'slotId': slotId,
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
      'semesterId': semesterId,
    };
  }
}
