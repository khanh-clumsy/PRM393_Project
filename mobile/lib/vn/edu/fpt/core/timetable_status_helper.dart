import 'package:flutter/material.dart';

class TimetableStatusHelper {
  static const int normal = 1;
  static const int rescheduled = 2;
  static const int cancelled = 3;
  static const int makeup = 4;

  static String label(int status) {
    switch (status) {
      case rescheduled:
        return 'Đổi lịch';
      case cancelled:
        return 'Nghỉ học';
      case makeup:
        return 'Dạy bù';
      default:
        return 'Bình thường';
    }
  }

  static Color color(int status) {
    switch (status) {
      case rescheduled:
        return Colors.blue;
      case cancelled:
        return Colors.grey;
      case makeup:
        return Colors.purple;
      default:
        return Colors.green;
    }
  }
}
