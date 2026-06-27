import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/student_class_model.dart';
import '../models/user_model.dart';
import '../models/class_model.dart';
import '../models/academic_year_model.dart';

class StudentClassController extends GetxController {
  final RxList<StudentClassModel> studentClasses = <StudentClassModel>[].obs;
  
  final RxList<AcademicYearModel> academicYears = <AcademicYearModel>[].obs;
  final RxList<ClassModel> classes = <ClassModel>[].obs;
  final RxList<UserModel> allStudents = <UserModel>[].obs;

  final RxnInt selectedYearId = RxnInt();
  final RxnInt selectedClassId = RxnInt();

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  List<ClassModel> get filteredClasses {
    if (selectedYearId.value == null) return [];
    return classes.where((c) => c.academicYearId == selectedYearId.value).toList();
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
        _fetchAcademicYears(),
        _fetchClasses(),
        _fetchStudents(),
      ]);
      if (classes.isNotEmpty) {
        // Automatically fetch students for the first selected class if available
        if (selectedClassId.value != null) {
          await fetchStudentClassesByClass(selectedClassId.value!);
        }
      }
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'Đã xảy ra lỗi hệ thống khi tải dữ liệu. Vui lòng thử lại sau.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchAcademicYears() async {
    final response = await ApiClient.instance.get('/api/academicyear');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      academicYears.value = data.map((json) => AcademicYearModel.fromJson(json)).toList();
      if (academicYears.isNotEmpty) {
        selectedYearId.value = academicYears.first.academicYearId;
      }
    }
  }

  Future<void> _fetchClasses() async {
    final response = await ApiClient.instance.get('/api/class');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      classes.value = data.map((json) => ClassModel.fromJson(json)).toList();
      
      // Update selected class
      if (filteredClasses.isNotEmpty) {
        selectedClassId.value = filteredClasses.first.classId;
      }
    }
  }

  Future<void> _fetchStudents() async {
    final response = await ApiClient.instance.get('/api/user/by-role/4'); // 4 is Student role
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      allStudents.value = data.map((json) => UserModel.fromJson(json)).toList();
    }
  }

  Future<void> fetchStudentClassesByClass(int classId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await ApiClient.instance.get('/api/studentclass/by-class/$classId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        var list = data.map((json) => StudentClassModel.fromJson(json)).toList();
        studentClasses.value = list;
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

  Future<void> addStudentToClass(int studentId, int classId) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/studentclass',
        data: {
          'studentId': studentId,
          'classId': classId,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back(); // close modal
        Get.snackbar('Thành công', 'Thêm học sinh vào lớp thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchStudentClassesByClass(classId); // refresh
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map && e.response!.data['message'] != null) {
        Get.snackbar('Lỗi', e.response!.data['message'], backgroundColor: Colors.redAccent, colorText: Colors.white);
      } else {
        Get.snackbar('Lỗi', 'Không thể thêm học sinh. Có thể học sinh này đã thuộc lớp khác.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi hệ thống. Vui lòng thử lại sau.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> removeStudentFromClass(int id, int classId) async {
    try {
      final response = await ApiClient.instance.delete('/api/studentclass/$id');
      if (response.statusCode == 204 || response.statusCode == 200) {
        Get.back(); // close confirm dialog
        Get.snackbar('Thành công', 'Xóa học sinh khỏi lớp thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchStudentClassesByClass(classId); // refresh
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa học sinh', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
