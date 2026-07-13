import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/submit/submit_guard_mixin.dart';
import '../models/academic_year_model.dart';

class AcademicYearController extends GetxController with SubmitGuardMixin {
  final RxList<AcademicYearModel> academicYears = <AcademicYearModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAcademicYears();
  }

  Future<void> fetchAcademicYears() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await ApiClient.instance.get('/api/academicyear');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        academicYears.value = AcademicYearModel.sortedChronologically(
          data.map((json) => AcademicYearModel.fromJson(json)),
        );
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

  Future<void> createAcademicYear(String name, String startDate, String endDate, bool isActive) async {
    await runSubmitting(() async {
      try {
        final response = await ApiClient.instance.post(
          '/api/academicyear',
          data: {
            'yearName': name,
            'startDate': startDate,
            'endDate': endDate,
            'isActive': isActive,
          },
        );
        if (response.statusCode == 201 || response.statusCode == 200) {
          closeDialogSafely();
          Get.snackbar('Thành công', 'Thêm năm học mới thành công', backgroundColor: Colors.green, colorText: Colors.white);
          fetchAcademicYears();
        }
      } catch (e) {
        Get.snackbar('Lỗi', 'Không thể thêm năm học', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    });
  }

  Future<void> updateAcademicYear(int id, String? name, String? startDate, String? endDate, bool? isActive) async {
    await runSubmitting(() async {
      try {
        final response = await ApiClient.instance.put(
          '/api/academicyear/$id',
          data: {
            'yearName': name,
            'startDate': startDate,
            'endDate': endDate,
            'isActive': isActive,
          },
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          closeDialogSafely();
          Get.snackbar('Thành công', 'Cập nhật năm học thành công', backgroundColor: Colors.green, colorText: Colors.white);
          fetchAcademicYears();
        }
      } catch (e) {
        Get.snackbar('Lỗi', 'Không thể cập nhật năm học', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    });
  }

  Future<void> deleteAcademicYear(int id) async {
    await runSubmitting(() async {
      try {
        final response = await ApiClient.instance.delete('/api/academicyear/$id');
        if (response.statusCode == 200 || response.statusCode == 204) {
          closeDialogSafely();
          Get.snackbar('Thành công', 'Xóa năm học thành công', backgroundColor: Colors.green, colorText: Colors.white);
          fetchAcademicYears();
        }
      } catch (e) {
        closeDialogSafely();
        Get.snackbar('Lỗi', 'Không thể xóa do ràng buộc dữ liệu (Khoá ngoại)', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    });
  }
}
