import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/submit/submit_guard_mixin.dart';
import '../core/auth/role_context.dart';
import '../models/teaching_assignment_model.dart';
import '../models/user_model.dart';
import '../models/class_model.dart';
import '../models/subject_model.dart';
import '../models/semester_model.dart';
import '../models/academic_year_model.dart';

class TeachingAssignmentController extends GetxController with SubmitGuardMixin {
  final ScopeMode scopeMode;
  TeachingAssignmentController({this.scopeMode = ScopeMode.admin});

  final RxList<TeachingAssignmentModel> assignments = <TeachingAssignmentModel>[].obs;
  final RxList<UserModel> teachers = <UserModel>[].obs;
  final RxList<ClassModel> classes = <ClassModel>[].obs;
  final RxList<SubjectModel> subjects = <SubjectModel>[].obs;
  final RxList<SemesterModel> semesters = <SemesterModel>[].obs;
  final RxList<AcademicYearModel> academicYears = <AcademicYearModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxnInt selectedYearId = RxnInt();
  final RxnInt selectedSemesterId = RxnInt();
  final RxnInt selectedClassId = RxnInt();

  List<SemesterModel> get filteredSemesters {
    if (selectedYearId.value == null) return [];
    return semesters.where((s) => s.academicYearId == selectedYearId.value).toList();
  }

  List<ClassModel> get filteredClasses {
    if (selectedYearId.value == null) return [];
    return classes.where((c) => c.academicYearId == selectedYearId.value).toList();
  }

  List<TeachingAssignmentModel> get filteredAssignments {
    if (selectedSemesterId.value == null || selectedClassId.value == null) return [];
    return assignments.where((a) => a.semesterId == selectedSemesterId.value && a.classId == selectedClassId.value).toList();
  }

  List<SubjectModel> get activeSubjects =>
      subjects.where((s) => s.isActive).toList();

  void onYearChanged(int yearId) {
    selectedYearId.value = yearId;
    if (filteredSemesters.isNotEmpty) {
      selectedSemesterId.value = filteredSemesters.first.semesterId;
    } else {
      selectedSemesterId.value = null;
    }
    if (filteredClasses.isNotEmpty) {
      selectedClassId.value = filteredClasses.first.classId;
    } else {
      selectedClassId.value = null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiClient.instance.get('/api/lookup/teaching-assignments');
      if (response.statusCode == 200) {
        final data = response.data;
        academicYears.value = AcademicYearModel.sortedChronologically(
          (data['academicYears'] as List).map((json) => AcademicYearModel.fromJson(json)),
        );
        semesters.value = (data['semesters'] as List).map((json) => SemesterModel.fromJson(json)).toList();
        classes.value = (data['classes'] as List).map((json) => ClassModel.fromJson(json)).toList();
        subjects.value = (data['subjects'] as List).map((json) => SubjectModel.fromJson(json)).toList();
        teachers.value = (data['teachers'] as List).map((json) => UserModel.fromJson(json)).toList();
        if (scopeMode == ScopeMode.head) {
          await _applyHeadScopeFilters();
        }
        
        await _fetchAssignments(); // Fetch actual assignments separately
      }
      if (academicYears.isNotEmpty) {
        final defaultYearId = AcademicYearModel.preferredDefaultId(academicYears);
        if (defaultYearId != null) {
          onYearChanged(defaultYearId);
        }
      }
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'Đã xảy ra lỗi hệ thống khi tải dữ liệu. Vui lòng thử lại sau.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAssignments() async {
    try {
      isLoading.value = true;
      await _fetchAssignments();
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng và thử lại.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchAssignments() async {
    if (scopeMode == ScopeMode.head) {
      final deptId = await RoleContext.departmentId;
      if (deptId == null) return;
      final response = await ApiClient.instance.get('/api/department/$deptId/assignments');
      if (response.statusCode == 200) {
        assignments.value = (response.data as List).map((json) => TeachingAssignmentModel.fromJson(json)).toList();
      }
      return;
    }
    final response = await ApiClient.instance.get('/api/teachingassignment');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      assignments.value = data.map((json) => TeachingAssignmentModel.fromJson(json)).toList();
    }
  }

  Future<void> _applyHeadScopeFilters() async {
    final deptId = await RoleContext.departmentId;
    if (deptId == null) return;
    final teacherRes = await ApiClient.instance.get('/api/department/$deptId/teachers');
    if (teacherRes.statusCode == 200) {
      teachers.value = (teacherRes.data as List).map((json) => UserModel.fromJson(json)).toList();
    }
    final assignRes = await ApiClient.instance.get('/api/department/$deptId/assignments');
    if (assignRes.statusCode == 200) {
      final classIds = (assignRes.data as List).map((e) => e['classId'] as int).toSet();
      classes.value = classes.where((c) => classIds.contains(c.classId)).toList();
    }
  }

  // Deleted individual fetch methods as they are handled by lookup API.

  Future<void> createAssignment(int teacherId, int classId, int subjectId, int semesterId) async {
    await runSubmitting(() async {
      try {
        final response = await ApiClient.instance.post(
          '/api/teachingassignment',
          data: {
            'teacherId': teacherId,
            'classId': classId,
            'subjectId': subjectId,
            'semesterId': semesterId,
          },
        );
        if (response.statusCode == 201 || response.statusCode == 200) {
          closeDialogSafely();
          Get.snackbar('Thành công', 'Phân công giảng dạy thành công', backgroundColor: Colors.green, colorText: Colors.white);
          fetchAssignments();
        }
      } on DioException catch (e) {
        if (e.response != null && e.response!.data is Map && e.response!.data['message'] != null) {
          Get.snackbar('Lỗi', e.response!.data['message'], backgroundColor: Colors.redAccent, colorText: Colors.white);
        } else {
          Get.snackbar('Lỗi', 'Không thể phân công giảng dạy (có thể do trùng lặp)', backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      } catch (e) {
        Get.snackbar('Lỗi', 'Lỗi hệ thống. Vui lòng thử lại sau.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    });
  }

  Future<void> updateAssignment(int id, int teacherId, int classId, int subjectId, int semesterId) async {
    await runSubmitting(() async {
      try {
        final response = await ApiClient.instance.put(
          '/api/teachingassignment/$id',
          data: {
            'teacherId': teacherId,
            'classId': classId,
            'subjectId': subjectId,
            'semesterId': semesterId,
          },
        );
        if (response.statusCode == 204 || response.statusCode == 200) {
          closeDialogSafely();
          Get.snackbar('Thành công', 'Cập nhật phân công thành công', backgroundColor: Colors.green, colorText: Colors.white);
          fetchAssignments();
        }
      } on DioException catch (e) {
        if (e.response != null && e.response!.data is Map && e.response!.data['message'] != null) {
          Get.snackbar('Lỗi', e.response!.data['message'], backgroundColor: Colors.redAccent, colorText: Colors.white);
        } else {
          Get.snackbar('Lỗi', 'Không thể cập nhật phân công', backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      } catch (e) {
        Get.snackbar('Lỗi', 'Lỗi hệ thống. Vui lòng thử lại sau.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    });
  }

  Future<void> deleteAssignment(int id) async {
    await runSubmitting(() async {
      try {
        final response = await ApiClient.instance.delete('/api/teachingassignment/$id');
        if (response.statusCode == 200 || response.statusCode == 204) {
          closeDialogSafely();
          Get.snackbar('Thành công', 'Hủy phân công thành công', backgroundColor: Colors.green, colorText: Colors.white);
          fetchAssignments();
        }
      } catch (e) {
        closeDialogSafely();
        Get.snackbar('Lỗi', 'Không thể hủy do ràng buộc dữ liệu (đã có TKB hoặc điểm số)', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    });
  }
}
