import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../core/network/api_client.dart';
import '../core/network/api_error_helper.dart';
import '../core/storage/local_storage.dart';
import '../models/academic_year_model.dart';
import '../models/semester_model.dart';

/// GVCN xem bảng tổng kết lớp (read-only GET).
class TeacherClassSummaryController extends GetxController {
  final classes = <Map<String, dynamic>>[].obs;
  final academicYears = <AcademicYearModel>[].obs;
  final semesters = <SemesterModel>[].obs;

  final selectedClassId = RxnInt();
  final selectedYearId = RxnInt();
  final selectedSemesterId = RxnInt();
  final boardMode = 'semester'.obs; // semester | yearly
  final rows = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  List<SemesterModel> get yearSemesters {
    final yid = selectedYearId.value;
    if (yid == null) return [];
    final list = semesters.where((s) => s.academicYearId == yid).toList();
    list.sort((a, b) => a.semesterId.compareTo(b.semesterId));
    return list;
  }

  String get yearLabel {
    final id = selectedYearId.value;
    if (id == null) return '';
    for (final y in academicYears) {
      if (y.academicYearId == id) return y.yearName;
    }
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    loadBootstrap();
  }

  Future<void> loadBootstrap() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final idStr = await LocalStorage.getUserId();
      final teacherId = int.tryParse(idStr ?? '');
      if (teacherId == null) {
        errorMessage.value = 'Không tìm thấy tài khoản giáo viên.';
        return;
      }

      final results = await Future.wait([
        ApiClient.instance.get('/api/class/by-homeroom/$teacherId'),
        ApiClient.instance.get('/api/academicyear'),
        ApiClient.instance.get('/api/semester'),
      ]);

      if (results[0].statusCode == 200) {
        classes.assignAll(
          (results[0].data as List).cast<Map<String, dynamic>>(),
        );
      }
      if (results[1].statusCode == 200) {
        academicYears.value = AcademicYearModel.sortedChronologically(
          (results[1].data as List)
              .map((e) => AcademicYearModel.fromJson(e as Map<String, dynamic>)),
        );
        selectedYearId.value = AcademicYearModel.preferredDefaultId(academicYears);
      }
      if (results[2].statusCode == 200) {
        semesters.value = (results[2].data as List)
            .map((e) => SemesterModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (classes.isEmpty) {
        errorMessage.value = 'Bạn chưa được phân công chủ nhiệm lớp nào.';
        rows.clear();
        selectedClassId.value = null;
        return;
      }

      selectedClassId.value = classes.first['classId'] as int?;
      _syncDefaultSemester();
      await loadBoard();
    } on DioException catch (e) {
      errorMessage.value =
          ApiErrorHelper.messageFrom(e, fallback: 'Không tải được dữ liệu.');
      classes.clear();
    } catch (e) {
      errorMessage.value = e.toString();
      classes.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void _syncDefaultSemester() {
    final list = yearSemesters;
    selectedSemesterId.value = list.isNotEmpty ? list.first.semesterId : null;
  }

  Future<void> loadBoard() async {
    final classId = selectedClassId.value;
    if (classId == null) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (boardMode.value == 'yearly') {
        final yearId = selectedYearId.value;
        if (yearId == null) {
          errorMessage.value = 'Chưa chọn năm học.';
          rows.clear();
          return;
        }
        final res = await ApiClient.instance
            .get('/api/class/$classId/summaries/yearly/$yearId');
        if (res.statusCode == 200) {
          rows.assignAll((res.data as List).cast<Map<String, dynamic>>());
        }
      } else {
        final semesterId = selectedSemesterId.value;
        if (semesterId == null) {
          errorMessage.value = 'Chưa chọn học kỳ.';
          rows.clear();
          return;
        }
        final res = await ApiClient.instance
            .get('/api/class/$classId/summaries/semester/$semesterId');
        if (res.statusCode == 200) {
          rows.assignAll((res.data as List).cast<Map<String, dynamic>>());
        }
      }
    } on DioException catch (e) {
      errorMessage.value =
          ApiErrorHelper.messageFrom(e, fallback: 'Không tải được tổng kết.');
      rows.clear();
    } catch (e) {
      errorMessage.value = e.toString();
      rows.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void selectClass(int classId) {
    selectedClassId.value = classId;
    loadBoard();
  }

  void onYearChanged(int? yearId) {
    if (yearId == null || yearId == selectedYearId.value) return;
    selectedYearId.value = yearId;
    _syncDefaultSemester();
    loadBoard();
  }

  void selectSemester(int semesterId) {
    selectedSemesterId.value = semesterId;
    if (boardMode.value == 'semester') loadBoard();
  }

  void setBoardMode(String mode) {
    boardMode.value = mode;
    loadBoard();
  }
}
