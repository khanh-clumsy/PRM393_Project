import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';
import '../models/department_model.dart';

class UserController extends GetxController {
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<DepartmentModel> departments = <DepartmentModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

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
    fetchUsers();
    fetchDepartments();
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
      errorMessage.value = 'Lỗi kết nối: ${e.message}';
    } catch (e) {
      errorMessage.value = 'Đã xảy ra lỗi: $e';
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
        Get.back();
        Get.snackbar('Thành công', 'Thêm tài khoản mới thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchUsers();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm tài khoản', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> updateUser(int id, String? fullName, int? roleId, int? departmentId, String? email, String? phone) async {
    try {
      final response = await ApiClient.instance.put(
        '/api/user/$id',
        data: {
          'fullName': fullName,
          'roleId': roleId,
          'departmentId': departmentId,
          'email': email,
          'phoneNumber': phone,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back();
        Get.snackbar('Thành công', 'Cập nhật tài khoản thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchUsers();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật tài khoản', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final response = await ApiClient.instance.delete('/api/user/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back();
        Get.snackbar('Thành công', 'Xóa tài khoản thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchUsers();
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Lỗi', 'Không thể xóa do ràng buộc dữ liệu', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
