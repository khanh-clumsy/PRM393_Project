import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/parent_student_model.dart';
import '../models/user_model.dart';

class ParentStudentController extends GetxController {
  final RxList<ParentStudentModel> parentStudents = <ParentStudentModel>[].obs;
  
  final RxList<UserModel> allParents = <UserModel>[].obs;
  final RxList<UserModel> allStudents = <UserModel>[].obs;

  final RxnInt selectedParentId = RxnInt();

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

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
        _fetchParents(),
        _fetchStudents(),
      ]);
      if (allParents.isNotEmpty) {
        selectedParentId.value = allParents.first.userId;
        await fetchByParent(selectedParentId.value!);
      } else {
        // No parents found, just stop loading
        isLoading.value = false;
      }
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'Đã xảy ra lỗi hệ thống khi tải dữ liệu. Vui lòng thử lại sau.';
      isLoading.value = false;
    }
  }

  Future<void> _fetchParents() async {
    final response = await ApiClient.instance.get('/api/user/by-role/5'); // 5 is Parent role
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      allParents.value = data.map((json) => UserModel.fromJson(json)).toList();
    }
  }

  Future<void> _fetchStudents() async {
    final response = await ApiClient.instance.get('/api/user/by-role/4'); // 4 is Student role
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      allStudents.value = data.map((json) => UserModel.fromJson(json)).toList();
    }
  }

  Future<void> fetchByParent(int parentId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await ApiClient.instance.get('/api/parentstudent/by-parent/$parentId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        var list = data.map((json) => ParentStudentModel.fromJson(json)).toList();
        
        parentStudents.value = list;
      }
    } on DioException catch (e) {
      print('DioException: $e');
      errorMessage.value = 'Không thể kết nối đến máy chủ.';
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'Lỗi không xác định.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createParentStudent(int parentId, int studentId, String relationship) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/parentstudent',
        data: {
          'parentId': parentId,
          'studentId': studentId,
          'relationship': relationship,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back(); // close modal
        Get.snackbar('Thành công', 'Thêm liên kết thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchByParent(parentId); // refresh
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm liên kết. Có thể đã tồn tại.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> updateParentStudent(int id, String relationship, int parentId) async {
    try {
      final response = await ApiClient.instance.put(
        '/api/parentstudent/$id',
        data: {
          'relationship': relationship,
        },
      );
      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar('Thành công', 'Cập nhật thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchByParent(parentId);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> deleteParentStudent(int id, int parentId) async {
    try {
      final response = await ApiClient.instance.delete('/api/parentstudent/$id');
      if (response.statusCode == 204 || response.statusCode == 200) {
        Get.back(); 
        Get.snackbar('Thành công', 'Xóa liên kết thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchByParent(parentId);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
