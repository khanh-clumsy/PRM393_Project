import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/teacher_attendance_controller.dart';
import '../../models/timetable_model.dart';
import '../../widgets/app_button.dart';

class TeacherAttendanceView extends StatefulWidget {
  final DateTime? initialDate;
  final int? initialTimetableId;

  const TeacherAttendanceView({
    super.key,
    this.initialDate,
    this.initialTimetableId,
  });

  @override
  State<TeacherAttendanceView> createState() => _TeacherAttendanceViewState();
}

class _TeacherAttendanceViewState extends State<TeacherAttendanceView> {
  static const _primary = Color(0xFFE65100);
  static const _bg = Color(0xFFF9FAFC);

  late final TeacherAttendanceController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<TeacherAttendanceController>()) {
      Get.delete<TeacherAttendanceController>();
    }
    controller = Get.put(TeacherAttendanceController(
      initialDate: widget.initialDate,
      initialTimetableId: widget.initialTimetableId,
    ));
  }

  @override
  void dispose() {
    if (Get.isRegistered<TeacherAttendanceController>()) {
      Get.delete<TeacherAttendanceController>();
    }
    super.dispose();
  }

  String _weekdayLabel(DateTime d) {
    if (d.weekday == DateTime.sunday) return 'Chủ nhật';
    return 'Thứ ${d.weekday + 1}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Điểm danh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.errorMessage.value.isNotEmpty && controller.teacherSlots.isEmpty) {
          return _buildErrorState();
        }

        if (controller.isLoading.value &&
            controller.teacherSlots.isEmpty &&
            controller.selectedSlot.value == null) {
          return const Center(child: CircularProgressIndicator(color: _primary));
        }

        return Column(
          children: [
            if (controller.selectedSlot.value == null)
              Expanded(child: _buildSlotPicker())
            else
              Expanded(child: _buildAttendanceForm()),
          ],
        );
      }),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(controller.errorMessage.value, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 20),
            AppButton.retry(onPressed: controller.loadTeacherSlots),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotPicker() {
    if (controller.teacherSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Không có tiết dạy trong ngày này', style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 4),
          child: Text(
            'Chọn tiết học (${controller.teacherSlots.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ...controller.teacherSlots.asMap().entries.map((e) {
          final index = e.key;
          final slot = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SlotCard(
              index: index + 1,
              slot: slot,
              onTap: () => controller.selectSlot(slot),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAttendanceForm() {
    final slot = controller.selectedSlot.value!;
    final date = controller.selectedDate.value;

    return Column(
      children: [
        _SessionHeader(
          slot: slot,
          date: date,
          weekdayLabel: _weekdayLabel(date),
          presentCount: controller.presentCount,
          absentCount: controller.absentCount,
          lateCount: controller.lateCount,
          totalStudents: controller.totalStudents,
          onChangeSlot: () {
            controller.selectedSlot.value = null;
            controller.entries.clear();
          },
          onMarkAllPresent: controller.markAllPresent,
          onMarkAllAbsent: controller.markAllAbsent,
        ),
        Expanded(
          child: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator(color: _primary))
              : controller.entries.isEmpty
                  ? Center(child: Text('Không có học sinh trong lớp.', style: TextStyle(color: Colors.grey.shade600)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: controller.entries.length,
                      itemBuilder: (context, index) {
                        final entry = controller.entries[index];
                        return _StudentAttendanceCard(
                          stt: index + 1,
                          entry: entry,
                          onStatus: (s) => controller.setStatus(entry.studentId, s),
                          onNote: (n) => controller.setNote(entry.studentId, n),
                        );
                      },
                    ),
        ),
        _buildSaveBar(),
      ],
    );
  }

  Widget _buildSaveBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AppButton.reactive(
          isLoading: controller.isSaving,
          icon: Icons.save_rounded,
          label: 'Lưu điểm danh',
          loadingLabel: 'Đang lưu...',
          fullWidth: true,
          height: 50,
          borderRadius: 14,
          onPressed: controller.saveAttendance,
        ),
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final int index;
  final TimetableModel slot;
  final VoidCallback onTap;

  const _SlotCard({required this.index, required this.slot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$index', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(slot.subjectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('${slot.className} · ${slot.slotName}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    Text(
                      '${slot.startTime.substring(0, 5)} – ${slot.endTime.substring(0, 5)}${slot.roomName != null && slot.roomName!.isNotEmpty ? ' · ${slot.roomName}' : ''}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionHeader extends StatelessWidget {
  final TimetableModel slot;
  final DateTime date;
  final String weekdayLabel;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int totalStudents;
  final VoidCallback onChangeSlot;
  final VoidCallback onMarkAllPresent;
  final VoidCallback onMarkAllAbsent;

  const _SessionHeader({
    required this.slot,
    required this.date,
    required this.weekdayLabel,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.totalStudents,
    required this.onChangeSlot,
    required this.onMarkAllPresent,
    required this.onMarkAllAbsent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.subjectName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                    ),
                    const SizedBox(height: 6),
                    _infoRow(Icons.class_rounded, 'Lớp ${slot.className}'),
                    _infoRow(Icons.calendar_today_rounded, '$weekdayLabel · ${DateFormat('dd/MM/yyyy').format(date)}'),
                    _infoRow(Icons.schedule_rounded, '${slot.slotName} · ${slot.startTime.substring(0, 5)} – ${slot.endTime.substring(0, 5)}'),
                    if (slot.roomName != null && slot.roomName!.trim().isNotEmpty)
                      _infoRow(Icons.meeting_room_outlined, 'Phòng ${slot.roomName}'),
                  ],
                ),
              ),
              TextButton(
                onPressed: onChangeSlot,
                child: const Text('Đổi tiết', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              _statPill('Có mặt', presentCount, Colors.green.shade100, Colors.green.shade800),
              const SizedBox(width: 8),
              _statPill('Vắng', absentCount, Colors.red.shade100, Colors.red.shade800),
              const SizedBox(width: 8),
              _statPill('Muộn', lateCount, Colors.orange.shade100, Colors.orange.shade900),
              const Spacer(),
              Text('$totalStudents HS', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Tất cả có mặt',
                  icon: Icons.done_all_rounded,
                  onPressed: onMarkAllPresent,
                  color: const Color(0xFF2E7D32),
                  height: 40,
                  borderRadius: 10,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'Tất cả vắng mặt',
                  icon: Icons.cancel_outlined,
                  onPressed: onMarkAllAbsent,
                  variant: AppButtonVariant.dangerOutlined,
                  height: 40,
                  borderRadius: 10,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade800, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _statPill(String label, int count, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text('$label: $count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}

class _StudentAttendanceCard extends StatelessWidget {
  final int stt;
  final TeacherAttendanceEntry entry;
  final ValueChanged<String> onStatus;
  final ValueChanged<String> onNote;

  const _StudentAttendanceCard({
    required this.stt,
    required this.entry,
    required this.onStatus,
    required this.onNote,
  });

  Color _statusAccent(String status) {
    switch (status) {
      case 'Absent':
        return Colors.red;
      case 'Late':
        return Colors.orange;
      default:
        return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _statusAccent(entry.status);
    final initials = _initials(entry.studentName);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$stt',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100), fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: accent.withValues(alpha: 0.12),
                  child: Text(initials, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accent)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.studentName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatusButton(label: 'Có mặt', value: 'Present', current: entry.status, color: Colors.green, onTap: onStatus)),
                const SizedBox(width: 8),
                Expanded(child: _StatusButton(label: 'Vắng', value: 'Absent', current: entry.status, color: Colors.red, onTap: onStatus)),
                const SizedBox(width: 8),
                Expanded(child: _StatusButton(label: 'Muộn', value: 'Late', current: entry.status, color: Colors.orange, onTap: onStatus)),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              key: ValueKey('note_${entry.studentId}_${entry.attendanceId}'),
              initialValue: entry.note,
              onChanged: onNote,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Ghi chú (tuỳ chọn)',
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final Color color;
  final ValueChanged<String> onTap;

  const _StatusButton({
    required this.label,
    required this.value,
    required this.current,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = current == value;
    return Material(
      color: selected ? color.withValues(alpha: 0.15) : const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => onTap(value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? color : Colors.transparent, width: 1.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected ? color : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
