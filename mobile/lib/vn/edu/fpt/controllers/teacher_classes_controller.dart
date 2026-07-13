import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';
import '../models/teaching_assignment_model.dart';
import '../models/semester_model.dart';
import '../models/academic_year_model.dart';

class TeacherClassesController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<TeachingAssignmentModel> assignments = <TeachingAssignmentModel>[].obs;
  final RxList<SemesterModel> semesters = <SemesterModel>[].obs;
  final RxList<AcademicYearModel> academicYears = <AcademicYearModel>[].obs;
  final RxnInt selectedYearId = RxnInt();
  final RxnInt selectedSemesterId = RxnInt();

  List<SemesterModel> get filteredSemesters {
    if (selectedYearId.value == null) return [];
    final list = semesters.where((s) => s.academicYearId == selectedYearId.value).toList();
    list.sort((a, b) => b.semesterId.compareTo(a.semesterId));
    return list;
  }

  List<TeachingAssignmentModel> get filteredAssignments {
    if (selectedSemesterId.value != null) {
      return _dedupeAssignments(
        assignments.where((a) => a.semesterId == selectedSemesterId.value).toList(),
      );
    }
    if (selectedYearId.value != null) {
      final semesterIds = filteredSemesters.map((s) => s.semesterId).toSet();
      return _dedupeAssignments(
        assignments.where((a) => semesterIds.contains(a.semesterId)).toList(),
      );
    }
    return _dedupeAssignments(assignments);
  }

  List<TeachingAssignmentModel> _dedupeAssignments(List<TeachingAssignmentModel> list) {
    final map = <String, TeachingAssignmentModel>{};
    for (final a in list) {
      final key = '${a.classId}_${a.subjectId}';
      final existing = map[key];
      if (existing == null || a.semesterId > existing.semesterId) {
        map[key] = a;
      }
    }
    final result = map.values.toList();
    result.sort((a, b) {
      final classCmp = (a.className ?? '').compareTo(b.className ?? '');
      if (classCmp != 0) return classCmp;
      return (a.subjectName ?? '').compareTo(b.subjectName ?? '');
    });
    return result;
  }

  void onYearChanged(int? yearId) {
    selectedYearId.value = yearId;
    final related = filteredSemesters;
    selectedSemesterId.value = related.isNotEmpty ? related.first.semesterId : null;
  }

  void onSemesterChanged(int? semesterId) {
    selectedSemesterId.value = semesterId;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final teacherId = int.tryParse(await LocalStorage.getUserId() ?? '');
      if (teacherId == null) {
        errorMessage.value = 'Không tìm thấy giáo viên.';
        return;
      }
      final results = await Future.wait([
        ApiClient.instance.get('/api/academicyear'),
        ApiClient.instance.get('/api/semester'),
        ApiClient.instance.get('/api/teachingassignment/by-teacher/$teacherId'),
      ]);

      if (results[0].statusCode == 200) {
        academicYears.value = AcademicYearModel.sortedChronologically(
          (results[0].data as List).map((e) => AcademicYearModel.fromJson(e)),
        );
      }
      if (results[1].statusCode == 200) {
        semesters.value = (results[1].data as List).map((e) => SemesterModel.fromJson(e)).toList();
      }
      if (results[2].statusCode == 200) {
        assignments.value = (results[2].data as List).map((e) => TeachingAssignmentModel.fromJson(e)).toList();
      }

      if (academicYears.isNotEmpty) {
        onYearChanged(AcademicYearModel.preferredDefaultId(academicYears));
      }
    } on DioException {
      errorMessage.value = 'Không thể tải lớp được phân công.';
    } finally {
      isLoading.value = false;
    }
  }
}
