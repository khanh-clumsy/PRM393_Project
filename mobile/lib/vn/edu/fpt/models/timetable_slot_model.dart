class TimetableSlotModel {
  final int slotId;
  final String slotName;
  final String startTime; // TimeOnly as string HH:mm
  final String endTime;   // TimeOnly as string HH:mm

  TimetableSlotModel({
    required this.slotId,
    required this.slotName,
    required this.startTime,
    required this.endTime,
  });

  factory TimetableSlotModel.fromJson(Map<String, dynamic> json) {
    return TimetableSlotModel(
      slotId: json['slotId'] as int,
      slotName: json['slotName'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slotId': slotId,
      'slotName': slotName,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
