import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/subject_model.dart';

class SubjectController extends GetxController {
  final RxList<SubjectModel> subjects = <SubjectModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await ApiClient.instance.get('/api/subject');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        subjects.value = data.map((json) => SubjectModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.message}';
    } catch (e) {
      errorMessage.value = 'Đã xảy ra lỗi: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSubject(String code, String name, bool isActive) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/subject',
        data: {
          'subjectCode': code,
          'subjectName': name,
          'isActive': isActive,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back();
        Get.snackbar('Thành công', 'Thêm môn học mới thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchSubjects();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm môn học', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> updateSubject(int id, String? code, String? name, bool? isActive) async {
    try {
      final response = await ApiClient.instance.put(
        '/api/subject/$id',
        data: {
          'subjectCode': code,
          'subjectName': name,
          'isActive': isActive,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back();
        Get.snackbar('Thành công', 'Cập nhật môn học thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchSubjects();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật môn học', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> deleteSubject(int id) async {
    try {
      final response = await ApiClient.instance.delete('/api/subject/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back();
        Get.snackbar('Thành công', 'Xóa môn học thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchSubjects();
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Lỗi', 'Không thể xóa do ràng buộc dữ liệu', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
