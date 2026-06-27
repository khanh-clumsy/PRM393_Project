import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/department_model.dart';

class DepartmentController extends GetxController {
  final RxList<DepartmentModel> departments = <DepartmentModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await ApiClient.instance.get('/api/department');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        departments.value = data.map((json) => DepartmentModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      print('DioException: $e');
      errorMessage.value = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng và thử lại.';
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createDepartment(String name, String? description) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/department',
        data: {
          'departmentName': name,
          'description': description,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back(); // Close dialog
        Get.snackbar('Thành công', 'Thêm phòng ban mới thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchDepartments();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm phòng ban', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> updateDepartment(int id, String name, String? description) async {
    try {
      final response = await ApiClient.instance.put(
        '/api/department/$id',
        data: {
          'departmentName': name,
          'description': description,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back(); // Close dialog
        Get.snackbar('Thành công', 'Cập nhật phòng ban thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchDepartments();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật phòng ban', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> deleteDepartment(int id) async {
    try {
      final response = await ApiClient.instance.delete('/api/department/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back(); // Close confirm dialog
        Get.snackbar('Thành công', 'Xóa phòng ban thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchDepartments();
      }
    } catch (e) {
      Get.back(); // Close confirm dialog
      Get.snackbar('Lỗi', 'Không thể xóa do ràng buộc dữ liệu (Khoá ngoại)', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
