import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/timetable_controller.dart';
import '../student/notifications_view.dart';

class TimetablePage extends StatelessWidget {
  const TimetablePage({super.key});

  bool _checkIfOngoing(String dateStr, String startStr, String endStr) {
    try {
      final now = DateTime.now();
      final dateStrFormatted = DateFormat('yyyy-MM-dd').format(now);
      if (dateStr.split('T')[0] != dateStrFormatted) return false;
      final timeStr = DateFormat('HH:mm:ss').format(now);
      return timeStr.compareTo(startStr) >= 0 && timeStr.compareTo(endStr) <= 0;
    } catch (_) {
      return false;
    }
  }

  bool _checkIsPast(String dateStr, String endStr) {
    try {
      final now = DateTime.now();
      final date = DateTime.parse(dateStr.split('T')[0]);
      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
      if (!isToday) return date.isBefore(now);
      final timeStr = DateFormat('HH:mm:ss').format(now);
      return timeStr.compareTo(endStr) > 0;
    } catch (_) {
      return false;
    }
  }

  double _getElapsedProgress(String startStr, String endStr) {
    try {
      final now = DateTime.now();
      final start = DateFormat('HH:mm:ss').parse(startStr);
      final end = DateFormat('HH:mm:ss').parse(endStr);
      final current = DateFormat('HH:mm:ss').parse(DateFormat('HH:mm:ss').format(now));
      final totalDuration = end.difference(start).inSeconds;
      final elapsed = current.difference(start).inSeconds;
      if (totalDuration <= 0) return 0.0;
      return (elapsed / totalDuration).clamp(0.0, 1.0);
    } catch (_) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TimetableController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Obx(() => Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFCC80), width: 1.5),
                  ),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFFFE0B2),
                    child: Icon(Icons.person, color: Color(0xFFE65100), size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'FSchool',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                    Text(
                      controller.studentName.value.isNotEmpty
                          ? controller.studentName.value
                          : 'Học sinh',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            )),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF424242), size: 26),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.timetables.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE65100)));
        }

        final weekDays = controller.currentWeekDays;
        final selectedDateStr = DateFormat('yyyy-MM-dd').format(controller.selectedDate.value);
        final monthYearStr = DateFormat('MMMM yyyy', 'vi_VN').format(controller.selectedDate.value);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown con (chỉ hiển thị khi phụ huynh có nhiều hơn 1 con)
              if (controller.userRole.value.toLowerCase() == 'parent' &&
                  controller.linkedStudents.length > 1) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: controller.targetStudentId.value,
                      hint: const Text('Chọn con'),
                      items: controller.linkedStudents.map((s) {
                        return DropdownMenuItem<int>(
                          value: s['studentId'],
                          child: Text(s['studentName'] ?? 'Học sinh'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.switchToStudent(val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Header: Tháng + Nút prev/next tuần
              Row(
                children: [
                  // Nút chọn tháng
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedDate.value,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        helpText: 'Chọn ngày',
                      );
                      if (picked != null) {
                        controller.selectedDate.value = picked;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 15, color: Color(0xFFE65100)),
                          const SizedBox(width: 5),
                          Text(
                            monthYearStr,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(Icons.arrow_drop_down_rounded, size: 18, color: Color(0xFFE65100)),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Nút prev/next tuần
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                          onTap: () => controller.selectedDate.value =
                              controller.selectedDate.value.subtract(const Duration(days: 7)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Icon(Icons.chevron_left_rounded, size: 20, color: Colors.grey.shade700),
                          ),
                        ),
                        Container(width: 1, height: 20, color: Colors.grey.shade200),
                        InkWell(
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                          onTap: () => controller.selectedDate.value =
                              controller.selectedDate.value.add(const Duration(days: 7)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Hàng 7 ngày — fit ngang màn hình, không scroll
              Row(
                children: List.generate(7, (index) {
                  final day = weekDays[index];
                  final isSelected = DateFormat('yyyy-MM-dd').format(day) == selectedDateStr;
                  final isToday = DateFormat('yyyy-MM-dd').format(day) ==
                      DateFormat('yyyy-MM-dd').format(DateTime.now());
                  final weekdayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                  final weekdayName = weekdayNames[day.weekday - 1];

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.selectedDate.value = day,
                      child: Container(
                        margin: EdgeInsets.only(right: index < 6 ? 4 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE65100) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : isToday
                                    ? const Color(0xFFE65100).withValues(alpha: 0.4)
                                    : Colors.grey.shade100,
                            width: isToday && !isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFE65100).withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              weekdayName,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : isToday
                                        ? const Color(0xFFE65100)
                                        : Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              day.day.toString(),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? const Color(0xFFE65100)
                                        : const Color(0xFF212121),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 3),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Danh sách lịch học
              controller.filteredTimetablesByDay.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Column(
                          children: [
                            Icon(Icons.event_available_outlined, size: 56, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'Không có lịch học hôm nay',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.filteredTimetablesByDay.length,
                      itemBuilder: (context, index) {
                        final t = controller.filteredTimetablesByDay[index];
                        final isOngoing = _checkIfOngoing(t.date, t.startTime, t.endTime);
                        final isPast = _checkIsPast(t.date, t.endTime);
                        final progress = _getElapsedProgress(t.startTime, t.endTime);

                        // Lấy điểm danh cho tiết này
                        final attendance = controller.getAttendanceForTimetable(t.timetableId);

                        return Column(
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Thời gian bên trái
                                  SizedBox(
                                    width: 60,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.startTime.substring(0, 5),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isOngoing ? const Color(0xFFE65100) : const Color(0xFF212121),
                                          ),
                                        ),
                                        Text(
                                          int.parse(t.startTime.substring(0, 2)) < 12 ? 'AM' : 'PM',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: isOngoing ? const Color(0xFFE65100) : Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Timeline dot
                                  Column(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: isOngoing
                                              ? const Color(0xFFE65100)
                                              : (t.status == 3 ? Colors.grey : Colors.grey.shade300),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: 1.5,
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),

                                  // Card tiết học
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: t.status == 3 ? Colors.grey.shade100 : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isOngoing
                                              ? const Color(0xFFE65100)
                                              : (t.status == 3 ? Colors.grey.shade300 : Colors.grey.shade100),
                                          width: isOngoing ? 1.5 : 1.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.02),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    t.subjectName,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: t.status == 3 ? Colors.grey : const Color(0xFF212121),
                                                      decoration: t.status == 3 ? TextDecoration.lineThrough : null,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                // Badge trạng thái lớp
                                                if (t.status == 3)
                                                  _buildStatusChip(
                                                      'Nghỉ học', Colors.red.shade100, Colors.red.shade700)
                                                else if (t.status == 4)
                                                  _buildStatusChip(
                                                      'Dạy bù', Colors.orange.shade100, Colors.orange.shade800)
                                                else if (t.roomName != null && t.roomName!.trim().isNotEmpty)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: isOngoing ? const Color(0xFFFFE0B2) : Colors.grey.shade100,
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      t.roomName!,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: isOngoing ? const Color(0xFFE65100) : Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.person_outline_rounded, size: 13, color: Colors.grey.shade600),
                                                const SizedBox(width: 5),
                                                Text(
                                                  t.teacherName,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time_rounded,
                                                  size: 13,
                                                  color: isOngoing ? const Color(0xFFE65100) : Colors.grey.shade500,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  '${t.startTime.substring(0, 5)} - ${t.endTime.substring(0, 5)} (${t.slotName})',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isOngoing ? const Color(0xFFE65100) : Colors.grey.shade600,
                                                    fontWeight: isOngoing ? FontWeight.bold : FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Badge điểm danh (chỉ hiện khi đã qua hoặc đang học)
                                            if (isPast || isOngoing) ...[
                                              const SizedBox(height: 8),
                                              _AttendanceBadge(
                                                attendance: attendance,
                                                isPast: isPast,
                                                isOngoing: isOngoing,
                                              ),
                                            ],

                                            if (isOngoing) ...[
                                              const SizedBox(height: 10),
                                              Stack(
                                                children: [
                                                  Container(
                                                    height: 4,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade200,
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                  ),
                                                  FractionallySizedBox(
                                                    widthFactor: progress,
                                                    child: Container(
                                                      height: 4,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFE65100),
                                                        borderRadius: BorderRadius.circular(2),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],

                                            if (t.note != null && t.note!.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                'Ghi chú: ${t.note}',
                                                style: TextStyle(
                                                  color: Colors.amber.shade900,
                                                  fontSize: 11,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              )
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusChip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}

class _AttendanceBadge extends StatelessWidget {
  final dynamic attendance;
  final bool isPast;
  final bool isOngoing;

  const _AttendanceBadge({
    required this.attendance,
    required this.isPast,
    required this.isOngoing,
  });

  @override
  Widget build(BuildContext context) {
    if (attendance == null) {
      if (isOngoing) {
        return _chip('Đang học', const Color(0xFFFFE0B2), const Color(0xFFE65100), Icons.schedule_rounded);
      }
      return _chip('Chưa điểm danh', Colors.grey.shade100, Colors.grey.shade500, Icons.help_outline_rounded);
    }

    final status = (attendance.status as String).toLowerCase();
    switch (status) {
      case 'present':
        return _chip('Có mặt', const Color(0xFFE8F5E9), const Color(0xFF2E7D32), Icons.check_circle_outline_rounded);
      case 'absent':
        return _chip('Vắng mặt', const Color(0xFFFFEBEE), const Color(0xFFC62828), Icons.cancel_outlined);
      case 'late':
        return _chip('Đi muộn', const Color(0xFFFFF8E1), const Color(0xFFF57F17), Icons.watch_later_outlined);
      case 'excused':
        return _chip('Có phép', const Color(0xFFE3F2FD), const Color(0xFF1565C0), Icons.assignment_turned_in_outlined);
      default:
        return _chip(attendance.status, Colors.grey.shade100, Colors.grey.shade600, Icons.info_outline);
    }
  }

  Widget _chip(String label, Color bg, Color fg, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
        ],
      ),
    );
  }
}
