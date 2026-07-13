import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/submit/submit_guard_mixin.dart';
import '../models/semester_model.dart';
import '../models/academic_year_model.dart';

class SemesterController extends GetxController with SubmitGuardMixin {
  final RxList<SemesterModel> semesters = <SemesterModel>[].obs;
  final RxList<AcademicYearModel> academicYears = <AcademicYearModel>[].obs;
  
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxnInt selectedYearId = RxnInt();

  List<SemesterModel> get filteredSemesters {
    if (selectedYearId.value == null) return [];
    return semesters.where((s) => s.academicYearId == selectedYearId.value).toList();
  }

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
      print('DioException: $e');
      errorMessage.value = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng và thử lại.';
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAcademicYears() async {
    try {
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
    } catch (e) {
      // Bỏ qua lỗi, vì list sẽ trống và dropdown không hiển thị
    }
  }

  Future<void> createSemester(int academicYearId, String name, String startDate, String endDate) async {
    await runSubmitting(() async {
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
          closeDialogSafely();
          Get.snackbar('Thành công', 'Thêm học kỳ mới thành công', backgroundColor: Colors.green, colorText: Colors.white);
          fetchSemesters();
        }
      } catch (e) {
        Get.snackbar('Lỗi', 'Không thể thêm học kỳ', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    });
  }

  Future<void> updateSemester(int id, String? name, String? startDate, String? endDate) async {
    await runSubmitting(() async {
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
          closeDialogSafely();
          Get.snackbar('Thành công', 'Cập nhật học kỳ thành công', backgroundColor: Colors.green, colorText: Colors.white);
          fetchSemesters();
        }
      } catch (e) {
        Get.snackbar('Lỗi', 'Không thể cập nhật học kỳ', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    });
  }

  Future<void> deleteSemester(int id) async {
    await runSubmitting(() async {
      try {
        final response = await ApiClient.instance.delete('/api/semester/$id');
        if (response.statusCode == 200 || response.statusCode == 204) {
          closeDialogSafely();
          Get.snackbar('Thành công', 'Xóa học kỳ thành công', backgroundColor: Colors.green, colorText: Colors.white);
          fetchSemesters();
        }
      } catch (e) {
        closeDialogSafely();
        Get.snackbar('Lỗi', 'Không thể xóa do ràng buộc dữ liệu', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    });
  }
}
