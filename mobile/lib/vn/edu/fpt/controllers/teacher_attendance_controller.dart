import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';
import '../models/attendance_model.dart';
import '../models/timetable_model.dart';

class TeacherAttendanceEntry {
  final int studentId;
  final String studentName;
  int? attendanceId;
  String status;
  String? note;

  TeacherAttendanceEntry({
    required this.studentId,
    required this.studentName,
    this.attendanceId,
    this.status = 'Present',
    this.note,
  });
}

class TeacherAttendanceController extends GetxController {
  final DateTime? initialDate;
  final int? initialTimetableId;

  TeacherAttendanceController({this.initialDate, this.initialTimetableId});

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<TimetableModel> teacherSlots = <TimetableModel>[].obs;
  final Rxn<TimetableModel> selectedSlot = Rxn<TimetableModel>();
  final RxList<TeacherAttendanceEntry> entries = <TeacherAttendanceEntry>[].obs;

  int? _teacherId;

  static DateTime _todayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool _isToday(DateTime date) {
    final today = _todayDate();
    return date.year == today.year && date.month == today.month && date.day == today.day;
  }

  bool get isSelectedDateToday => _isToday(selectedDate.value);

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    final userId = await LocalStorage.getUserId();
    _teacherId = int.tryParse(userId ?? '');
    if (_teacherId == null) {
      errorMessage.value = 'Không tìm thấy thông tin giáo viên.';
      return;
    }
    selectedDate.value = _todayDate();
    await loadTeacherSlots();
    if (initialTimetableId != null) {
      final slot = teacherSlots.firstWhereOrNull((t) => t.timetableId == initialTimetableId);
      if (slot != null) {
        await selectSlot(slot);
      }
    }
  }

  Future<void> loadTeacherSlots() async {
    if (_teacherId == null) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final response = await ApiClient.instance.get(
        '/api/timetable/weekly/by-teacher/$_teacherId?date=$dateStr',
      );
      if (response.statusCode == 200) {
        teacherSlots.value = (response.data as List)
            .map((json) => TimetableModel.fromJson(json))
            .where((t) => t.date.split('T')[0] == dateStr)
            .toList();
        selectedSlot.value = null;
        entries.clear();
      }
    } on DioException {
      errorMessage.value = 'Không thể tải lịch dạy.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectSlot(TimetableModel slot) async {
    selectedSlot.value = slot;
    await _loadStudentsAndAttendance(slot);
  }

  Future<void> _loadStudentsAndAttendance(TimetableModel slot) async {
    isLoading.value = true;
    try {
      final classStudentsRes = await ApiClient.instance.get('/api/studentclass/by-class/${slot.classId}');
      final attendanceRes = await ApiClient.instance.get('/api/attendance/by-timetable/${slot.timetableId}');

      final attendanceMap = <int, Map<String, dynamic>>{};
      if (attendanceRes.statusCode == 200) {
        for (final item in attendanceRes.data as List) {
          attendanceMap[item['studentId'] as int] = item;
        }
      }

      final list = <TeacherAttendanceEntry>[];
      if (classStudentsRes.statusCode == 200) {
        for (final sc in classStudentsRes.data as List) {
          final studentId = sc['studentId'] as int;
          final existing = attendanceMap[studentId];
          list.add(TeacherAttendanceEntry(
            studentId: studentId,
            studentName: sc['studentName']?.toString() ?? 'HS #$studentId',
            attendanceId: existing?['attendanceId'] as int?,
            status: AttendanceStatusMapper.toApiName(existing?['status']?.toString() ?? 'Present'),
            note: existing?['note'] as String?,
          ));
        }
      }
      entries.value = list;
    } catch (e) {
      errorMessage.value = 'Không thể tải danh sách học sinh.';
    } finally {
      isLoading.value = false;
    }
  }

  void setStatus(int studentId, String status) {
    final idx = entries.indexWhere((e) => e.studentId == studentId);
    if (idx >= 0) entries[idx].status = status;
    entries.refresh();
  }

  void setNote(int studentId, String note) {
    final idx = entries.indexWhere((e) => e.studentId == studentId);
    if (idx >= 0) entries[idx].note = note;
    entries.refresh();
  }

  int get presentCount => entries.where((e) => e.status == 'Present').length;
  int get absentCount => entries.where((e) => e.status == 'Absent').length;
  int get lateCount => entries.where((e) => e.status == 'Late').length;
  int get totalStudents => entries.length;

  void markAllPresent() {
    for (final e in entries) {
      e.status = 'Present';
    }
    entries.refresh();
  }

  void markAllAbsent() {
    for (final e in entries) {
      e.status = 'Absent';
    }
    entries.refresh();
  }

  Future<void> saveAttendance() async {
    final slot = selectedSlot.value;
    if (slot == null || _teacherId == null) return;

    if (!isSelectedDateToday) {
      Get.snackbar(
        'Không thể lưu',
        'Chỉ được điểm danh trong ngày hôm nay.',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return;
    }

    isSaving.value = true;
    try {
      final toCreate = entries.where((e) => e.attendanceId == null).toList();
      final toUpdate = entries.where((e) => e.attendanceId != null).toList();

      if (toCreate.isNotEmpty) {
        await ApiClient.instance.post(
          '/api/attendance/bulk',
          data: toCreate
              .map((e) => {
                    'timetableId': slot.timetableId,
                    'studentId': e.studentId,
                    'status': AttendanceStatusMapper.toApiCode(e.status),
                    'note': e.note,
                    'recordedBy': _teacherId,
                  })
              .toList(),
        );
      }

      if (toUpdate.isNotEmpty) {
        await ApiClient.instance.put(
          '/api/attendance/bulk',
          data: toUpdate
              .map((e) => {
                    'attendanceId': e.attendanceId,
                    'status': AttendanceStatusMapper.toApiCode(e.status),
                    'note': e.note,
                  })
              .toList(),
        );
      }

      Get.snackbar('Thành công', 'Đã lưu điểm danh', backgroundColor: Colors.green, colorText: Colors.white);
      await _loadStudentsAndAttendance(slot);
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? e.response?.data['message'] : null;
      Get.snackbar('Lỗi', msg?.toString() ?? 'Không thể lưu điểm danh', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }
}
