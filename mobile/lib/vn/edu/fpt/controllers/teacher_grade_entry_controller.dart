import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:prm393_mobile/vn/edu/fpt/models/grade_model.dart';
import 'package:prm393_mobile/vn/edu/fpt/models/teaching_assignment_model.dart';
import 'package:prm393_mobile/vn/edu/fpt/models/academic_year_model.dart';
import 'package:prm393_mobile/vn/edu/fpt/models/semester_model.dart';
import 'package:prm393_mobile/vn/edu/fpt/models/assessment_type_model.dart';
import 'package:prm393_mobile/vn/edu/fpt/core/network/api_client.dart';
import 'package:prm393_mobile/vn/edu/fpt/core/storage/local_storage.dart';

class TeacherGradeEntryController extends GetxController {
  var isLoading = false.obs;
  var isSaving = false.obs;
  var errorMessage = ''.obs;

  var academicYears = <AcademicYearModel>[].obs;
  var selectedAcademicYearId = RxnInt();

  var allSemesters = <SemesterModel>[].obs;
  var filteredSemesters = <SemesterModel>[].obs;
  var selectedSemesterId = RxnInt();

  var allAssignments = <TeachingAssignmentModel>[].obs;
  var filteredAssignments = <TeachingAssignmentModel>[].obs;
  var selectedAssignmentId = RxnInt();

  var assessmentTypes = <AssessmentTypeModel>[].obs;
  var selectedAssessmentTypeId = RxnInt();

  var students = <StudentGradeByTypeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    isLoading(true);
    errorMessage('');
    try {
      final teacherId = int.tryParse(await LocalStorage.getUserId() ?? '');
      if (teacherId == null) return;

      // Parallel fetch for initial lookup data
      final responses = await Future.wait([
        ApiClient.instance.get('/api/academicyear'),
        ApiClient.instance.get('/api/semester'),
        ApiClient.instance.get('/api/teachingassignment/by-teacher/$teacherId'),
        ApiClient.instance.get('/api/assessmenttype'),
      ]);

      academicYears.value = (responses[0].data as List).map((j) => AcademicYearModel.fromJson(j)).toList();
      allSemesters.value = (responses[1].data as List).map((j) => SemesterModel.fromJson(j)).toList();
      allAssignments.value = (responses[2].data as List).map((j) => TeachingAssignmentModel.fromJson(j)).toList();
      assessmentTypes.value = (responses[3].data as List).map((j) => AssessmentTypeModel.fromJson(j)).toList();

      // Auto-select first Year
      if (academicYears.isNotEmpty) {
        onYearChanged(academicYears.first.academicYearId);
      }
      if (assessmentTypes.isNotEmpty) {
        selectedAssessmentTypeId.value = assessmentTypes.first.assessmentTypeId;
      }
    } on DioException catch (e) {
      errorMessage('Lỗi khi tải dữ liệu: ${e.message}');
    } finally {
      isLoading(false);
    }
  }

  void onYearChanged(int? yearId) {
    selectedAcademicYearId.value = yearId;
    filteredSemesters.value = allSemesters.where((s) => s.academicYearId == yearId).toList();
    
    if (filteredSemesters.isNotEmpty) {
      onSemesterChanged(filteredSemesters.first.semesterId);
    } else {
      onSemesterChanged(null);
    }
  }

  void onSemesterChanged(int? semesterId) {
    selectedSemesterId.value = semesterId;
    filteredAssignments.value = allAssignments.where((a) => a.semesterId == semesterId).toList();

    if (filteredAssignments.isNotEmpty) {
      onAssignmentChanged(filteredAssignments.first.teachingAssignmentId);
    } else {
      onAssignmentChanged(null);
    }
  }

  void onAssignmentChanged(int? assignmentId) {
    selectedAssignmentId.value = assignmentId;
    fetchStudents();
  }

  void onAssessmentTypeChanged(int? typeId) {
    selectedAssessmentTypeId.value = typeId;
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    if (selectedAssignmentId.value == null || selectedAssessmentTypeId.value == null) {
      students.clear();
      return;
    }

    try {
      isLoading(true);
      errorMessage('');
      final response = await ApiClient.instance.get(
        '/api/grade/class-grades-by-type',
        queryParameters: {
          'teachingAssignmentId': selectedAssignmentId.value,
          'assessmentTypeId': selectedAssessmentTypeId.value,
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        students.value = data.map((j) => StudentGradeByTypeModel.fromJson(j)).toList();
      }
    } on DioException catch (e) {
      errorMessage('Lỗi tải danh sách học sinh: ${e.message}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> saveGrades() async {
    if (selectedAssignmentId.value == null || selectedAssessmentTypeId.value == null) return;
    
    try {
      isSaving(true);
      errorMessage('');

      final payload = BulkGradeByTypeModel(
        teachingAssignmentId: selectedAssignmentId.value!,
        assessmentTypeId: selectedAssessmentTypeId.value!,
        students: students.map((s) => StudentScoreModel(
          studentId: s.studentId,
          score: s.score,
          comment: s.comment,
        )).toList(),
      );

      final response = await ApiClient.instance.post(
        '/api/grade/bulk-by-type',
        data: payload.toJson(),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Thành công', 'Lưu điểm thành công!',
            backgroundColor: const Color(0xFFE8F5E9),
            colorText: const Color(0xFF2E7D32));
        fetchStudents();
      }
    } on DioException catch (e) {
      errorMessage('Lỗi khi lưu điểm: ${e.message}');
      Get.snackbar('Lỗi', 'Không thể lưu điểm',
          backgroundColor: const Color(0xFFFFEBEE),
          colorText: const Color(0xFFC62828));
    } finally {
      isSaving(false);
    }
  }
}
