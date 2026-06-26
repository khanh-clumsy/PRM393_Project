import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/semester_model.dart';
import '../models/academic_year_model.dart';

class SemesterController extends GetxController {
  final RxList<SemesterModel> semesters = <SemesterModel>[].obs;
  final RxList<AcademicYearModel> academicYears = <AcademicYearModel>[].obs;
  
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSemesters();
    fetchAcademicYears();
  }

  Future<void> fetchSemesters() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await ApiClient.instance.get('/api/semester');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        semesters.value = data.map((json) => SemesterModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.message}';
    } catch (e) {
      errorMessage.value = 'Đã xảy ra lỗi: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAcademicYears() async {
    try {
      final response = await ApiClient.instance.get('/api/academicyear');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        academicYears.value = data.map((json) => AcademicYearModel.fromJson(json)).toList();
      }
    } catch (e) {
      // Bỏ qua lỗi, vì list sẽ trống và dropdown không hiển thị
    }
  }

  Future<void> createSemester(int academicYearId, String name, String startDate, String endDate) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/semester',
        data: {
          'academicYearId': academicYearId,
          'semesterName': name,
          'startDate': startDate,
          'endDate': endDate,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back();
        Get.snackbar('Thành công', 'Thêm học kỳ mới thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchSemesters();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm học kỳ', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> updateSemester(int id, String? name, String? startDate, String? endDate) async {
    try {
      final response = await ApiClient.instance.put(
        '/api/semester/$id',
        data: {
          'semesterName': name,
          'startDate': startDate,
          'endDate': endDate,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back();
        Get.snackbar('Thành công', 'Cập nhật học kỳ thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchSemesters();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật học kỳ', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> deleteSemester(int id) async {
    try {
      final response = await ApiClient.instance.delete('/api/semester/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back();
        Get.snackbar('Thành công', 'Xóa học kỳ thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchSemesters();
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Lỗi', 'Không thể xóa do ràng buộc dữ liệu', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
