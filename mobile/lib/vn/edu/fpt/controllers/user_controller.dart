import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_error_helper.dart';
import '../core/storage/local_storage.dart';
import '../core/submit/submit_guard_mixin.dart';
import '../models/user_model.dart';
import '../models/department_model.dart';

class UserController extends GetxController with SubmitGuardMixin {
  UserController({this.profileOnly = false});

  /// Chỉ load hồ sơ user đang đăng nhập (dùng cho màn Student).
  final bool profileOnly;

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<DepartmentModel> departments = <DepartmentModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxString currentUserFullName = 'Học sinh'.obs;

  String get welcomeText => 'Xin chào, ${currentUserFullName.value}';

  final List<Map<String, dynamic>> roles = [
    {'id': 1, 'name': 'Quản trị viên'},
    {'id': 2, 'name': 'Trưởng bộ môn'},
    {'id': 3, 'name': 'Giáo viên'},
    {'id': 4, 'name': 'Học sinh'},
    {'id': 5, 'name': 'Phụ huynh'},
  ];

  @override
  void onInit() {
    super.onInit();
    if (profileOnly) {
      fetchCurrentUser();
    } else {
      fetchUsers();
      fetchDepartments();
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final userId = await LocalStorage.getUserId();
      if (userId == null) return;

      final response = await ApiClient.instance.get('/api/user/$userId');
      if (response.statusCode == 200) {
        final name = response.data['fullName']?.toString().trim();
        if (name != null && name.isNotEmpty) {
          currentUserFullName.value = name;
        }
      }
    } on DioException catch (e) {
      errorMessage.value = ApiErrorHelper.messageFrom(
        e,
        fallback: 'Không thể tải thông tin người dùng.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await ApiClient.instance.get('/api/user');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        users.value = data.map((json) => UserModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      print('DioException: $e');
      errorMessage.value = ApiErrorHelper.messageFrom(
        e,
        fallback: 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng và thử lại.',
      );
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDepartments() async {
    try {
      final response = await ApiClient.instance.get('/api/department');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        departments.value = data.map((json) => DepartmentModel.fromJson(json)).toList();
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> createUser(String username, String password, String fullName, int roleId, int? departmentId, String? email, String? phone) async {
    await runSubmitting(() async {
      try {
        final response = await ApiClient.instance.post(
          '/api/user',
          data: {
            'username': username,
            'password': password, // Must be sent for Create
            'fullName': fullName,
            'roleId': roleId,
            'departmentId': departmentId,
            'email': email,
            'phoneNumber': phone,
          },
        );
        if (response.statusCode == 201 || response.statusCode == 200) {
          closeDialogSafely();
          Get.snackbar('Thành công', 'Thêm tài khoản mới thành công', backgroundColor: Colors.green, colorText: Colors.white);
          fetchUsers();
        }
      } catch (e) {
        Get.snackbar('Lỗi', ApiErrorHelper.messageFrom(e, fallback: 'Không thể thêm tài khoản'), backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    });
  }

  Future<void> updateUser(int id, String? fullName, int? roleId, int? departmentId, String? email, String? phone, {bool? isActive, bool closeDialog = true}) async {
    await runSubmitting(() async {
      try {
        final data = <String, dynamic>{
          'fullName': fullName,
          'roleId': roleId,
          'departmentId': departmentId,
          'email': email,
          'phoneNumber': phone,
        };
        if (isActive != null) data['isActive'] = isActive;
        final response = await ApiClient.instance.put(
          '/api/user/$id',
          data: data,
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          if (closeDialog) closeDialogSafely();
          Get.snackbar('Thành công', 'Cập nhật tài khoản thành công', backgroundColor: Colors.green, colorText: Colors.white);
          fetchUsers();
        }
      } catch (e) {
        Get.snackbar('Lỗi', ApiErrorHelper.messageFrom(e, fallback: 'Không thể cập nhật tài khoản'), backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    });
  }

  Future<void> toggleUserActive(UserModel user) async {
    await runSubmitting(() async {
      try {
        final response = await ApiClient.instance.put(
          '/api/user/${user.userId}',
          data: {'isActive': !user.isActive},
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          Get.snackbar(
            'Thành công',
            user.isActive ? 'Đã khóa tài khoản' : 'Đã mở khóa tài khoản',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          fetchUsers();
        }
      } catch (e) {
        Get.snackbar(
          'Lỗi',
          ApiErrorHelper.messageFrom(e, fallback: 'Không thể cập nhật trạng thái tài khoản'),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    });
  }

  Future<void> deleteUser(int id) async {
    await runSubmitting(() async {
      try {
        final response = await ApiClient.instance.delete('/api/user/$id');
        if (response.statusCode == 200 || response.statusCode == 204) {
          closeDialogSafely();
          Get.snackbar('Thành công', 'Xóa tài khoản thành công', backgroundColor: Colors.green, colorText: Colors.white);
          fetchUsers();
        }
      } catch (e) {
        Get.snackbar('Lỗi', ApiErrorHelper.messageFrom(e, fallback: 'Không thể xóa do ràng buộc dữ liệu'), backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    });
  }
}
