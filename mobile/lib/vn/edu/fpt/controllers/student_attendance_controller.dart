import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';
import '../models/academic_year_model.dart';

class AttendanceDetailItem {
  final int timetableId;
  final DateTime date;
  final String slotName;
  final String? roomName;
  final String status;
  final String? note;

  AttendanceDetailItem({
    required this.timetableId,
    required this.date,
    required this.slotName,
    this.roomName,
    required this.status,
    this.note,
  });

  factory AttendanceDetailItem.fromJson(Map<String, dynamic> json) {
    return AttendanceDetailItem(
      timetableId: json['timetableId'] as int,
      date: DateTime.parse(json['date'] as String),
      slotName: json['slotName'] as String,
      roomName: json['roomName'] as String?,
      status: json['status'] as String,
      note: json['note'] as String?,
    );
  }
}

class SubjectAttendanceStats {
  final int subjectId;
  final String subjectName;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final int totalCount;
  final List<AttendanceDetailItem> details;

  SubjectAttendanceStats({
    required this.subjectId,
    required this.subjectName,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.excusedCount,
    required this.totalCount,
    required this.details,
  });

  double get attendanceRate =>
      totalCount == 0 ? 0.0 : (presentCount + lateCount) / totalCount;

  factory SubjectAttendanceStats.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List? ?? [];
    return SubjectAttendanceStats(
      subjectId: json['subjectId'] as int,
      subjectName: json['subjectName'] as String,
      presentCount: json['presentCount'] as int,
      absentCount: json['absentCount'] as int,
      lateCount: json['lateCount'] as int,
      excusedCount: json['excusedCount'] as int,
      totalCount: json['totalCount'] as int,
      details: detailsList.map((d) => AttendanceDetailItem.fromJson(d)).toList(),
    );
  }
}

class SemesterAttendanceSummary {
  final int totalPresent;
  final int totalAbsent;
  final int totalLate;
  final int totalExcused;
  final List<SubjectAttendanceStats> subjects;

  SemesterAttendanceSummary({
    required this.totalPresent,
    required this.totalAbsent,
    required this.totalLate,
    required this.totalExcused,
    required this.subjects,
  });

  factory SemesterAttendanceSummary.fromJson(Map<String, dynamic> json) {
    var subjectsList = json['subjects'] as List? ?? [];
    return SemesterAttendanceSummary(
      totalPresent: json['totalPresent'] ?? 0,
      totalAbsent: json['totalAbsent'] ?? 0,
      totalLate: json['totalLate'] ?? 0,
      totalExcused: json['totalExcused'] ?? 0,
      subjects: subjectsList.map((j) => SubjectAttendanceStats.fromJson(j)).toList(),
    );
  }
}


class StudentAttendanceController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Id học sinh đang xem
  final RxnInt targetStudentId = RxnInt();
  final RxString targetStudentName = ''.obs;

  // Danh sách con (cho phụ huynh)
  final RxList<Map<String, dynamic>> linkedStudents =
      <Map<String, dynamic>>[].obs;

  // Các dữ liệu danh mục tải từ backend
  final RxList<dynamic> academicYears = <dynamic>[].obs;
  final RxList<dynamic> semesters = <dynamic>[].obs;

  // Lọc
  final RxnInt selectedYearId = RxnInt();
  final RxnInt selectedSemesterId = RxnInt();

  // Thống kê điểm danh của học kỳ đang chọn
  final Rxn<SemesterAttendanceSummary> attendanceSummary = Rxn<SemesterAttendanceSummary>();

  // Helper cho danh sách subjects (giữ tương thích)
  List<SubjectAttendanceStats> get subjectStatsList => attendanceSummary.value?.subjects ?? [];

  // Danh sách học kỳ thuộc năm học đang chọn
  List<dynamic> get filteredSemesters {
    if (selectedYearId.value == null) return [];
    return semesters.where((s) => s['academicYearId'] == selectedYearId.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();

    // Khi đổi năm học -> Tự động cập nhật học kỳ mặc định
    ever(selectedYearId, (yearId) {
      if (yearId != null) {
        final related = semesters.where((s) => s['academicYearId'] == yearId).toList();
        if (related.isNotEmpty) {
          related.sort((a, b) => (b['semesterId'] as int).compareTo(a['semesterId'] as int));
          selectedSemesterId.value = related.first['semesterId'];
        } else {
          selectedSemesterId.value = null;
        }
      } else {
        selectedSemesterId.value = null;
      }
    });

    // Khi đổi học kỳ -> Load dữ liệu summary mới
    ever(selectedSemesterId, (semId) {
      if (semId != null && targetStudentId.value != null) {
        fetchSummaryData();
      } else {
        attendanceSummary.value = null;
      }
    });
  }

  Future<void> fetchInitialData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final role = await LocalStorage.getRole();
      final userIdStr = await LocalStorage.getUserId();
      if (userIdStr == null) {
        errorMessage.value = 'Không tìm thấy thông tin người dùng.';
        return;
      }
      final userId = int.parse(userIdStr);

      // Load Năm học và Học kỳ cục bộ
      await Future.wait([
        _fetchAcademicYears(),
        _fetchSemesters(),
      ]);

      if (academicYears.isNotEmpty) {
        AcademicYearModel.sortMaps(academicYears);
        selectedYearId.value = AcademicYearModel.preferredDefaultIdFromMaps(academicYears);
      }

      if (role?.toLowerCase() == 'parent') {
        await _resolveStudentFromParent(userId);
      } else {
        targetStudentId.value = userId;
        await _fetchStudentName(userId);
        if (selectedSemesterId.value != null) {
          await fetchSummaryData();
        }
      }
    } catch (e) {
      errorMessage.value = 'Đã xảy ra lỗi khi tải dữ liệu.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchAcademicYears() async {
    final res = await ApiClient.instance.get('/api/academicyear');
    if (res.statusCode == 200 && res.data is List) {
      final years = List<dynamic>.from(res.data as List);
      AcademicYearModel.sortMaps(years);
      academicYears.value = years;
    }
  }

  Future<void> _fetchSemesters() async {
    final res = await ApiClient.instance.get('/api/semester');
    if (res.statusCode == 200 && res.data is List) {
      semesters.value = res.data;
    }
  }

  Future<void> _resolveStudentFromParent(int parentId) async {
    final res = await ApiClient.instance.get('/api/parentstudent/dashboard/$parentId');
    if (res.statusCode == 200) {
      final data = res.data;
      if (data['children'] is List) {
        final list = data['children'] as List;
        if (list.isEmpty) {
          errorMessage.value = 'Tài khoản này chưa được liên kết với học sinh nào.';
          return;
        }
        linkedStudents.value = list.map<Map<String, dynamic>>((e) => {
          'parentStudentId': e['parentStudentId'],
          'studentId': e['studentId'],
          'studentName': e['studentName'] ?? 'Học sinh',
          'relationship': e['relationship'] ?? '',
        }).toList();

        final firstStudent = linkedStudents.first;
        targetStudentId.value = firstStudent['studentId'];
        targetStudentName.value = firstStudent['studentName'] ?? '';
        if (selectedSemesterId.value != null) {
          await fetchSummaryData();
        }
      }
    }
  }

  Future<void> _fetchStudentName(int studentId) async {
    try {
      final res = await ApiClient.instance.get('/api/user/$studentId');
      if (res.statusCode == 200) {
        targetStudentName.value = res.data['fullName'] ?? '';
      }
    } catch (_) {}
  }

  Future<void> fetchSummaryData() async {
    if (targetStudentId.value == null || selectedSemesterId.value == null) return;
    isLoading.value = true;
    try {
      final url = '/api/attendance/student/${targetStudentId.value}/semester/${selectedSemesterId.value}';
      final res = await ApiClient.instance.get(url);
      if (res.statusCode == 200 && res.data != null) {
        attendanceSummary.value = SemesterAttendanceSummary.fromJson(res.data);
      } else {
        attendanceSummary.value = null;
      }
    } catch (e) {
      errorMessage.value = 'Không thể tải thống kê điểm danh.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> switchToStudent(int studentId, String studentName) async {
    if (targetStudentId.value == studentId) return;
    targetStudentId.value = studentId;
    targetStudentName.value = studentName;
    if (selectedSemesterId.value != null) {
      await fetchSummaryData();
    }
  }
}
