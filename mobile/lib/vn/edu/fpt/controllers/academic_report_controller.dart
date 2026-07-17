import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../core/network/api_client.dart';
import '../core/network/api_error_helper.dart';
import '../core/storage/local_storage.dart';
import '../models/academic_year_model.dart';
import '../models/grade_model.dart';
import 'timetable_controller.dart';

/// Học bạ theo năm học — reuse yearly-transcript (GPA/conduct/rank từ summary).
class AcademicReportController extends GetxController {
  AcademicReportController({this.initialStudentId, this.initialStudentName});

  final int? initialStudentId;
  final String? initialStudentName;

  final RxnInt targetStudentId = RxnInt();
  final RxString targetStudentName = ''.obs;
  final RxList<Map<String, dynamic>> linkedStudents = <Map<String, dynamic>>[].obs;

  final academicYears = <AcademicYearModel>[].obs;
  final selectedYearId = RxnInt();
  final report = Rxn<YearlyTranscriptModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    bootstrap();
  }

  Future<void> bootstrap() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (initialStudentId != null) {
        targetStudentId.value = initialStudentId;
        targetStudentName.value = initialStudentName?.trim() ?? '';
      } else {
        final userIdStr = await LocalStorage.getUserId();
        final id = int.tryParse(userIdStr ?? '');
        if (id == null) {
          errorMessage.value = 'Không tìm thấy tài khoản.';
          return;
        }
        final role = (await LocalStorage.getRole())?.toLowerCase();
        if (role == 'parent') {
          await _resolveFromParent(id);
        } else {
          targetStudentId.value = id;
          await _fetchStudentName(id);
        }
      }
      if (targetStudentId.value != null) {
        await loadYears();
      }
    } catch (e) {
      errorMessage.value = 'Không khởi tạo được học bạ: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _resolveFromParent(int parentId) async {
    final res = await ApiClient.instance.get('/api/parentstudent/dashboard/$parentId');
    if (res.statusCode != 200 || res.data['children'] is! List) {
      errorMessage.value = 'Không tải được danh sách con.';
      return;
    }
    final list = res.data['children'] as List;
    if (list.isEmpty) {
      errorMessage.value = 'Chưa có học sinh được liên kết.';
      return;
    }
    linkedStudents.value = list
        .map<Map<String, dynamic>>((e) => {
              'studentId': e['studentId'],
              'studentName': e['studentName'] ?? 'Học sinh',
            })
        .toList();

    int? preferId;
    if (Get.isRegistered<TimetableController>()) {
      preferId = Get.find<TimetableController>().targetStudentId.value;
    }
    final preferred = linkedStudents.firstWhereOrNull((s) => s['studentId'] == preferId);
    final initial = preferred ?? linkedStudents.first;
    targetStudentId.value = initial['studentId'] as int;
    targetStudentName.value = initial['studentName'] as String? ?? '';
  }

  Future<void> _fetchStudentName(int studentId) async {
    try {
      final res = await ApiClient.instance.get('/api/user/$studentId');
      if (res.statusCode == 200) {
        targetStudentName.value = res.data['fullName'] ?? '';
      }
    } catch (_) {}
  }

  Future<void> switchToStudent(int studentId, String studentName) async {
    if (targetStudentId.value == studentId) return;
    targetStudentId.value = studentId;
    targetStudentName.value = studentName;
    if (Get.isRegistered<TimetableController>()) {
      await Get.find<TimetableController>().switchToStudent(studentId);
    }
    await loadReport();
  }

  Future<void> loadYears() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await ApiClient.instance.get('/api/academicyear');
      if (res.statusCode == 200) {
        academicYears.value = AcademicYearModel.sortedChronologically(
          (res.data as List).map((e) => AcademicYearModel.fromJson(e as Map<String, dynamic>)),
        );
        if (academicYears.isNotEmpty) {
          selectedYearId.value = AcademicYearModel.preferredDefaultId(academicYears);
          await loadReport();
          return;
        }
        errorMessage.value = 'Chưa có năm học.';
      }
    } on DioException catch (e) {
      errorMessage.value = ApiErrorHelper.messageFrom(e, fallback: 'Không tải được năm học.');
    } catch (e) {
      errorMessage.value = 'Không tải được năm học: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadReport() async {
    final yearId = selectedYearId.value;
    final studentId = targetStudentId.value;
    if (yearId == null || studentId == null) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await ApiClient.instance.get(
        '/api/grade/yearly-transcript/$studentId',
        queryParameters: {'academicYearId': yearId},
      );
      if (res.statusCode == 200) {
        report.value = YearlyTranscriptModel.fromJson(res.data as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      errorMessage.value = ApiErrorHelper.messageFrom(e, fallback: 'Không tải được học bạ.');
      report.value = null;
    } catch (e) {
      errorMessage.value = 'Không tải được học bạ: $e';
      report.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  void onYearChanged(int? yearId) {
    if (yearId == null || yearId == selectedYearId.value) return;
    selectedYearId.value = yearId;
    loadReport();
  }
}
