import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/auth/role_context.dart';
import '../models/user_model.dart';
import '../models/teaching_assignment_model.dart';

class HeadDeptController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<UserModel> teachers = <UserModel>[].obs;
  final RxList<TeachingAssignmentModel> assignments = <TeachingAssignmentModel>[].obs;

  int? _departmentId;

  @override
  void onInit() {
    super.onInit();
    _loadDepartmentData();
  }

  Future<void> _loadDepartmentData() async {
    _departmentId = await RoleContext.departmentId;
    if (_departmentId == null) {
      errorMessage.value = 'Không tìm thấy thông tin tổ chuyên môn.';
      isLoading.value = false;
      return;
    }
    await refreshAll();
  }

  Future<void> refreshAll() async {
    if (_departmentId == null) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.wait([
        fetchTeachers(),
        fetchAssignments(),
      ]);
    } catch (e) {
      errorMessage.value = 'Không thể tải dữ liệu tổ chuyên môn.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTeachers() async {
    final response = await ApiClient.instance.get('/api/department/$_departmentId/teachers');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      teachers.value = data.map((json) => UserModel.fromJson(json)).toList();
    }
  }

  Future<void> fetchAssignments() async {
    final response = await ApiClient.instance.get('/api/department/$_departmentId/assignments');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      assignments.value = data.map((json) => TeachingAssignmentModel.fromJson(json)).toList();
    }
  }
}

class HeadDeptTeachersController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<UserModel> teachers = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final deptId = await RoleContext.departmentId;
    if (deptId == null) {
      errorMessage.value = 'Không tìm thấy tổ chuyên môn.';
      isLoading.value = false;
      return;
    }
    try {
      final response = await ApiClient.instance.get('/api/department/$deptId/teachers');
      if (response.statusCode == 200) {
        teachers.value = (response.data as List).map((e) => UserModel.fromJson(e)).toList();
      }
    } on DioException {
      errorMessage.value = 'Không thể tải danh sách giáo viên.';
    } finally {
      isLoading.value = false;
    }
  }
}

class HeadDeptAssignmentsController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<TeachingAssignmentModel> assignments = <TeachingAssignmentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final deptId = await RoleContext.departmentId;
    if (deptId == null) {
      errorMessage.value = 'Không tìm thấy tổ chuyên môn.';
      isLoading.value = false;
      return;
    }
    try {
      final response = await ApiClient.instance.get('/api/department/$deptId/assignments');
      if (response.statusCode == 200) {
        assignments.value = (response.data as List).map((e) => TeachingAssignmentModel.fromJson(e)).toList();
      }
    } on DioException {
      errorMessage.value = 'Không thể tải phân công giảng dạy.';
    } finally {
      isLoading.value = false;
    }
  }
}
