import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_error_helper.dart';
import '../core/submit/submit_guard_mixin.dart';
import '../core/auth/role_context.dart';
import '../models/class_model.dart';
import '../models/academic_year_model.dart';
import '../models/user_model.dart';

class ClassController extends GetxController with SubmitGuardMixin {
  final ScopeMode scopeMode;
  ClassController({this.scopeMode = ScopeMode.admin});

  final RxList<ClassModel> classes = <ClassModel>[].obs;
  final RxList<AcademicYearModel> academicYears = <AcademicYearModel>[].obs;
  final RxList<UserModel> teachers = <UserModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxnInt selectedYearId = RxnInt();

  List<ClassModel> get filteredClasses {
    if (selectedYearId.value == null) return [];
    return classes.where((c) => c.academicYearId == selectedYearId.value).toList();
  }

  List<UserModel> getAvailableTeachers(int academicYearId, int? currentClassId) {
    final assignedTeacherIds = classes
        .where((c) => c.academicYearId == academicYearId && c.homeroomTeacherId != null && c.classId != currentClassId)
        .map((c) => c.homeroomTeacherId!)
        .toSet();
    
    return teachers.where((t) => !assignedTeacherIds.contains(t.userId)).toList();
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
      await Future.wait([
        _fetchClasses(),
        _fetchAcademicYears(),
        _fetchTeachers(),
      ]);
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'Đã xảy ra lỗi hệ thống khi tải dữ liệu. Vui lòng thử lại sau.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchClasses() async {
    try {
      isLoading.value = true;
      await _fetchClasses();
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng và thử lại.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchClasses() async {
    final response = await ApiClient.instance.get('/api/class');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      var loaded = data.map((json) => ClassModel.fromJson(json)).toList();
      if (scopeMode == ScopeMode.head) {
        loaded = await _filterClassesForHead(loaded);
      }
      classes.value = loaded;
    }
  }

  Future<List<ClassModel>> _filterClassesForHead(List<ClassModel> all) async {
    final deptId = await RoleContext.departmentId;
    if (deptId == null) return all;
    final assignRes = await ApiClient.instance.get('/api/department/$deptId/assignments');
    final teacherRes = await ApiClient.instance.get('/api/department/$deptId/teachers');
    if (assignRes.statusCode != 200) return all;
    final classIds = (assignRes.data as List).map((e) => e['classId'] as int).toSet();
    final teacherIds = teacherRes.statusCode == 200
        ? (teacherRes.data as List).map((e) => e['id'] as int).toSet()
        : <int>{};
    return all
        .where((c) => classIds.contains(c.classId) || (c.homeroomTeacherId != null && teacherIds.contains(c.homeroomTeacherId)))
        .toList();
  }

  Future<void> _fetchTeachers() async {
    if (scopeMode == ScopeMode.head) {
      final deptId = await RoleContext.departmentId;
      if (deptId == null) return;
      final response = await ApiClient.instance.get('/api/department/$deptId/teachers');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        teachers.value = data.map((json) => UserModel.fromJson(json)).toList();
      }
      return;
    }
    final response = await ApiClient.instance.get('/api/user/by-role/3'); // 3 is Teacher role
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      teachers.value = data.map((json) => UserModel.fromJson(json)).toList();
    }
  }

  Future<void> _fetchAcademicYears() async {
    final response = await ApiClient.instance.get('/api/academicyear');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        academicYears.value = AcademicYearModel.sortedChronologically(
          data.map((json) => AcademicYearModel.fromJson(json)),
        );
        if (academicYears.isNotEmpty) {
          selectedYearId.value = AcademicYearModel.preferredDefaultId(academicYears);
        }
      }
  }

  Future<void> createClass(String name, int academicYearId, int? homeroomTeacherId) async {
    await runSubmitting(() async {
      try {
        final response = await ApiClient.instance.post(
          '/api/class',
          data: {
            'className': name,
            'academicYearId': academicYearId,
            'homeroomTeacherId': homeroomTeacherId,
          },
        );
        if (response.statusCode == 201 || response.statusCode == 200) {
          closeDialogSafely();
          Get.snackbar('Thành công', 'Thêm lớp học thành công', backgroundColor: Colors.green, colorText: Colors.white);
          fetchClasses();
        }
      } catch (e) {
        Get.snackbar('Lỗi', ApiErrorHelper.messageFrom(e, fallback: 'Không thể thêm lớp học'), backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    });
  }

  Future<void> updateClass(int id, String? name, int? homeroomTeacherId) async {
    await runSubmitting(() async {
      try {
        final response = await ApiClient.instance.put(
          '/api/class/$id',
          data: {
            'className': name,
            'homeroomTeacherId': homeroomTeacherId,
          },
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          closeDialogSafely();
          Get.snackbar('Thành công', 'Cập nhật lớp học thành công', backgroundColor: Colors.green, colorText: Colors.white);
          fetchClasses();
        }
      } catch (e) {
        Get.snackbar('Lỗi', ApiErrorHelper.messageFrom(e, fallback: 'Không thể cập nhật lớp học'), backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    });
  }

  Future<void> deleteClass(int id) async {
    await runSubmitting(() async {
      try {
        final response = await ApiClient.instance.delete('/api/class/$id');
        if (response.statusCode == 200 || response.statusCode == 204) {
          closeDialogSafely();
          Get.snackbar('Thành công', 'Xóa lớp học thành công', backgroundColor: Colors.green, colorText: Colors.white);
          fetchClasses();
        }
      } catch (e) {
        closeDialogSafely();
        Get.snackbar('Lỗi', ApiErrorHelper.messageFrom(e, fallback: 'Không thể xóa do ràng buộc dữ liệu'), backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    });
  }
}
