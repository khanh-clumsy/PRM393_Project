import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';
import '../models/timetable_model.dart';
import '../models/timetable_template_model.dart';
import '../models/teaching_assignment_model.dart';
import '../models/timetable_slot_model.dart';
import '../models/user_model.dart';
import '../models/class_model.dart';
import '../models/subject_model.dart';
import '../models/semester_model.dart';
import '../models/academic_year_model.dart';
import '../models/attendance_model.dart';

class TimetableController extends GetxController {
  final RxList<TimetableModel> timetables = <TimetableModel>[].obs;
  final RxList<TimetableTemplateModel> templates = <TimetableTemplateModel>[].obs;
  final RxList<TeachingAssignmentModel> assignments = <TeachingAssignmentModel>[].obs;
  final RxList<TimetableSlotModel> slots = <TimetableSlotModel>[].obs;
  
  final RxList<UserModel> teachers = <UserModel>[].obs;
  final RxList<ClassModel> classes = <ClassModel>[].obs;
  final RxList<SubjectModel> subjects = <SubjectModel>[].obs;
  final RxList<SemesterModel> semesters = <SemesterModel>[].obs;
  final RxList<AcademicYearModel> academicYears = <AcademicYearModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Filters
  final RxnInt selectedYearId = RxnInt();
  final RxnInt selectedSemesterId = RxnInt();
  final RxnInt selectedClassId = RxnInt();
  
  // Real Date Mode properties
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  
  // Master Mode properties
  final RxBool isMasterMode = false.obs;
  final RxInt selectedMasterDay = 2.obs; // 2 (Mon) to 8 (Sun)
  
  final RxString userRole = ''.obs;
  final RxString studentName = ''.obs;

  // Student/Parent: studentId đang xem
  final RxnInt targetStudentId = RxnInt();
  // Danh sách con (chỉ dùng cho parent)
  final RxList<Map<String, dynamic>> linkedStudents = <Map<String, dynamic>>[].obs;
  // Điểm danh của ngày đang xem (dùng để hiển thị badge trên card)
  final RxList<AttendanceModel> attendanceForDay = <AttendanceModel>[].obs;

  List<SemesterModel> get filteredSemesters {
    if (selectedYearId.value == null) return [];
    return semesters.where((s) => s.academicYearId == selectedYearId.value).toList();
  }

  List<ClassModel> get filteredClasses {
    if (selectedYearId.value == null) return [];
    return classes.where((c) => c.academicYearId == selectedYearId.value).toList();
  }

  List<DateTime> get currentWeekDays {
    final date = selectedDate.value;
    int diff = date.weekday - DateTime.monday;
    final monday = date.subtract(Duration(days: diff));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  List<TimetableModel> get filteredTimetablesByDay {
    if (selectedClassId.value == null) return [];
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    return timetables.where((t) => t.date.split('T')[0] == dateStr).toList();
  }

  List<TimetableTemplateModel> get filteredTemplatesByDay {
    if (selectedClassId.value == null) return [];
    return templates.where((t) => t.dayOfWeek == selectedMasterDay.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
    
    ever(isMasterMode, (val) {
      if (selectedClassId.value != null) {
        if (val) {
          fetchTimetableTemplates();
        } else {
          fetchWeeklyTimetables();
        }
      }
    });

    everAll([selectedClassId, selectedSemesterId, selectedDate], (_) {
      if (selectedClassId.value != null) {
        if (isMasterMode.value) {
          fetchTimetableTemplates();
        } else {
          fetchWeeklyTimetables();
        }
      }
      // Cập nhật điểm danh khi đổi ngày (chỉ dành cho student/parent view)
      if (targetStudentId.value != null &&
          (userRole.value.toLowerCase() == 'student' ||
              userRole.value.toLowerCase() == 'parent')) {
        fetchAttendanceForDay(targetStudentId.value!, selectedDate.value);
      }
    });
  }

  Future<void> fetchInitialData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final role = await LocalStorage.getRole();
      userRole.value = role ?? '';

      final lookupRes = await ApiClient.instance.get('/api/lookup/teaching-assignments');
      if (lookupRes.statusCode == 200) {
        final data = lookupRes.data;
        academicYears.value = (data['academicYears'] as List).map((json) => AcademicYearModel.fromJson(json)).toList();
        semesters.value = (data['semesters'] as List).map((json) => SemesterModel.fromJson(json)).toList();
        classes.value = (data['classes'] as List).map((json) => ClassModel.fromJson(json)).toList();
        subjects.value = (data['subjects'] as List).map((json) => SubjectModel.fromJson(json)).toList();
        teachers.value = (data['teachers'] as List).map((json) => UserModel.fromJson(json)).toList();
        slots.value = (data['slots'] as List).map((json) => TimetableSlotModel.fromJson(json)).toList();
      }
      await _fetchAssignments();

      if (userRole.value.toLowerCase() == 'student') {
        final userIdStr = await LocalStorage.getUserId();
        if (userIdStr != null) {
          int studentId = int.parse(userIdStr);
          targetStudentId.value = studentId;
          // Fetch student name for display
          final userRes = await ApiClient.instance.get('/api/user/$studentId');
          if (userRes.statusCode == 200) {
            studentName.value = userRes.data['fullName'] ?? 'Học sinh';
          }
          // Fetch student class
          final response = await ApiClient.instance.get('/api/studentclass/by-student/$studentId');
          if (response.statusCode == 200 && response.data is List && (response.data as List).isNotEmpty) {
            selectedClassId.value = response.data[0]['classId'];
          }
          // Fetch attendance for current day
          await fetchAttendanceForDay(studentId, selectedDate.value);
        }
      } else if (userRole.value.toLowerCase() == 'parent') {
        final userIdStr = await LocalStorage.getUserId();
        if (userIdStr != null) {
          final parentId = int.parse(userIdStr);
          await _resolveStudentFromParent(parentId);
        }
      } else {
        if (academicYears.isNotEmpty) {
          selectedYearId.value = academicYears.first.academicYearId;
          if (filteredSemesters.isNotEmpty) {
            selectedSemesterId.value = filteredSemesters.first.semesterId;
          }
          if (filteredClasses.isNotEmpty) {
            selectedClassId.value = filteredClasses.first.classId;
          }
        }
      }
    } catch (e) {
      print('Error loading initial data: $e');
      errorMessage.value = 'Đã xảy ra lỗi hệ thống khi tải dữ liệu. Vui lòng thử lại sau.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWeeklyTimetables() async {
    if (selectedClassId.value == null) return;
    try {
      isLoading.value = true;
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final response = await ApiClient.instance.get('/api/timetable/weekly/by-class/${selectedClassId.value}?date=$dateStr');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        timetables.value = data.map((json) => TimetableModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      print('DioException: $e');
      errorMessage.value = 'Không thể lấy dữ liệu thời khóa biểu tuần.';
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'Không thể lấy dữ liệu thời khóa biểu tuần.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTimetableTemplates() async {
    if (selectedClassId.value == null) return;
    try {
      isLoading.value = true;
      String url = '/api/timetable/template/by-class/${selectedClassId.value}';
      if (selectedSemesterId.value != null) {
        url += '?semesterId=${selectedSemesterId.value}';
      }
      final response = await ApiClient.instance.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        templates.value = data.map((json) => TimetableTemplateModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      print('DioException templates: $e');
    } catch (e) {
      print('Error templates: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchAssignments() async {
    final response = await ApiClient.instance.get('/api/teachingassignment');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      assignments.value = data.map((json) => TeachingAssignmentModel.fromJson(json)).toList();
    }
  }

  // Removed individual fetches handled by lookup API.

  Future<void> _resolveStudentFromParent(int parentId) async {
    try {
      final res = await ApiClient.instance.get('/api/parentstudent/dashboard/$parentId');
      if (res.statusCode == 200) {
        final data = res.data;
        studentName.value = data['parentName'] ?? 'Phụ huynh';

        if (data['children'] is List && (data['children'] as List).isNotEmpty) {
          linkedStudents.value = (data['children'] as List).map<Map<String, dynamic>>((e) {
            return {
              'parentStudentId': e['parentStudentId'],
              'studentId': e['studentId'],
              'studentName': e['studentName'] ?? 'Học sinh',
              'relationship': e['relationship'] ?? '',
              'classId': e['classId'],
              'className': e['className'],
              'attendanceToday': e['attendanceToday']
            };
          }).toList();

          final firstStudent = linkedStudents.first;
          targetStudentId.value = firstStudent['studentId'];
          selectedClassId.value = firstStudent['classId'];

          // Lấy điểm danh của ngày hiện tại (nếu có từ backend) hoặc load lại
          if (firstStudent['attendanceToday'] != null) {
             attendanceForDay.value = (firstStudent['attendanceToday'] as List)
                .map((j) => AttendanceModel.fromJson(j))
                .toList();
          } else {
             await fetchAttendanceForDay(targetStudentId.value!, selectedDate.value);
          }
        }
      }
    } catch (e) {
      print('Error resolving student from parent dashboard: $e');
    }
  }

  Future<void> switchToStudent(int studentId) async {
    if (targetStudentId.value == studentId) return;
    targetStudentId.value = studentId;
    // Lấy lớp của con mới
    try {
      final classRes =
          await ApiClient.instance.get('/api/studentclass/by-student/$studentId');
      if (classRes.statusCode == 200 &&
          classRes.data is List &&
          (classRes.data as List).isNotEmpty) {
        selectedClassId.value = classRes.data[0]['classId'];
      }
      await fetchAttendanceForDay(studentId, selectedDate.value);
    } catch (e) {
      print('Error switching student: $e');
    }
  }

  Future<void> fetchAttendanceForDay(int studentId, DateTime date) async {
    try {
      final res =
          await ApiClient.instance.get('/api/attendance/by-student/$studentId');
      if (res.statusCode == 200 && res.data is List) {
        final allRecords = (res.data as List)
            .map((j) => AttendanceModel.fromJson(j))
            .toList();
        // Filter chỉ lấy records trong ngày được chọn
        attendanceForDay.value = allRecords.where((r) {
          final d = r.recordedAt;
          return d.year == date.year &&
              d.month == date.month &&
              d.day == date.day;
        }).toList();
      }
    } catch (_) {
      attendanceForDay.value = [];
    }
  }

  AttendanceModel? getAttendanceForTimetable(int timetableId) {
    return attendanceForDay.firstWhereOrNull((r) => r.timetableId == timetableId);
  }

  Future<void> createTimetable(int taId, String date, int slotId, String roomName) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/timetable',
        data: {
          'teachingAssignmentId': taId,
          'date': date,
          'slotId': slotId,
          'roomName': roomName,
          'status': 1,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back();
        Get.snackbar('Thành công', 'Xếp thời khóa biểu thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchWeeklyTimetables();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xếp TKB (có thể trùng lịch)', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> createTimetableTemplate(int taId, int dayOfWeek, int slotId, String roomName) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/timetable/template',
        data: {
          'teachingAssignmentId': taId,
          'dayOfWeek': dayOfWeek,
          'slotId': slotId,
          'roomName': roomName,
        },
      );
      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar('Thành công', 'Thêm lịch mẫu thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchTimetableTemplates();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm lịch mẫu (có thể trùng lịch)', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> updateTimetableStatus(int id, int status, String? note) async {
    try {
      final response = await ApiClient.instance.put(
        '/api/timetable/$id',
        data: {
          'status': status,
          'note': note,
        },
      );
      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar('Thành công', 'Cập nhật trạng thái tiết học thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchWeeklyTimetables();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> generateFromDatabaseTemplates() async {
    if (selectedSemesterId.value == null || selectedClassId.value == null) return;
    try {
      isLoading.value = true;
      final response = await ApiClient.instance.post(
        '/api/timetable/generate-from-template/${selectedSemesterId.value}/${selectedClassId.value}',
      );
      if (response.statusCode == 200) {
        Get.snackbar('Thành công', 'Sinh lịch từ Master thành công cho cả học kỳ!', backgroundColor: Colors.green, colorText: Colors.white);
        isMasterMode.value = false; // Chuyển về chế độ lịch thực tế để xem kết quả
        fetchWeeklyTimetables();
      }
    } catch (e) {
      print('DEBUG ERROR [generateFromDatabaseTemplates]: $e');
      if (e is DioException) {
        print('DioException response: ${e.response?.statusCode} - ${e.response?.data}');
      }
      Get.snackbar(
        'Lỗi',
        'Không thể sinh lịch học kỳ. Vui lòng kiểm tra cấu hình Master hoặc thử lại sau.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTimetable(int id) async {
    try {
      final response = await ApiClient.instance.delete('/api/timetable/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back();
        Get.snackbar('Thành công', 'Xóa TKB thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchWeeklyTimetables();
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Lỗi', 'Không thể xóa do ràng buộc dữ liệu', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> deleteTimetableTemplate(int id) async {
    try {
      final response = await ApiClient.instance.delete('/api/timetable/template/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back();
        Get.snackbar('Thành công', 'Xóa lịch mẫu thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchTimetableTemplates();
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Lỗi', 'Không thể xóa lịch mẫu', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> clearGeneratedTimetables() async {
    if (selectedSemesterId.value == null || selectedClassId.value == null) return;
    try {
      isLoading.value = true;
      final response = await ApiClient.instance.post(
        '/api/timetable/clear-generated/${selectedSemesterId.value}/${selectedClassId.value}',
      );
      if (response.statusCode == 200) {
        Get.snackbar('Thành công', 'Đã xóa toàn bộ lịch học đã sinh!', backgroundColor: Colors.orange, colorText: Colors.white);
        fetchWeeklyTimetables();
      }
    } catch (e) {
      print('DEBUG ERROR [clearGeneratedTimetables]: $e');
      if (e is DioException) {
        print('DioException response: ${e.response?.statusCode} - ${e.response?.data}');
      }
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi xóa lịch học đã sinh. Vui lòng thử lại sau.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTimetableTemplate(int id, int taId, int dayOfWeek, int slotId, String roomName) async {
    try {
      final response = await ApiClient.instance.put(
        '/api/timetable/template/$id',
        data: {
          'teachingAssignmentId': taId,
          'dayOfWeek': dayOfWeek,
          'slotId': slotId,
          'roomName': roomName,
        },
      );
      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar('Thành công', 'Cập nhật lịch mẫu thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchTimetableTemplates();
      }
    } catch (e) {
      print('DEBUG ERROR [updateTimetableTemplate]: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật lịch mẫu (có thể trùng lịch)', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> updateTimetableDetail(int id, int taId, int slotId, String roomName) async {
    try {
      final response = await ApiClient.instance.put(
        '/api/timetable/$id',
        data: {
          'teachingAssignmentId': taId,
          'slotId': slotId,
          'roomName': roomName,
        },
      );
      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar('Thành công', 'Cập nhật tiết học thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchWeeklyTimetables();
      }
    } catch (e) {
      print('DEBUG ERROR [updateTimetableDetail]: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật tiết học', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> updateSemesterDate(int semesterId, String startDate, String endDate) async {
    try {
      isLoading.value = true;
      final currentSem = semesters.firstWhereOrNull((s) => s.semesterId == semesterId);
      if (currentSem == null) return;

      final response = await ApiClient.instance.put(
        '/api/semester/$semesterId',
        data: {
          'semesterName': currentSem.semesterName,
          'startDate': startDate,
          'endDate': endDate,
        },
      );
      if (response.statusCode == 200) {
        Get.snackbar('Thành công', 'Cập nhật thời gian học kỳ thành công', backgroundColor: Colors.green, colorText: Colors.white);
        await fetchInitialData();
      }
    } catch (e) {
      print('Error updating semester: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật thời gian học kỳ', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
