import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/student_class_model.dart';

class TeacherClassStudentsController extends GetxController {
  final int classId;
  final String className;
  final String subjectName;

  TeacherClassStudentsController({
    required this.classId,
    required this.className,
    required this.subjectName,
  });

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<StudentClassModel> students = <StudentClassModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiClient.instance.get('/api/studentclass/by-class/$classId');
      if (response.statusCode == 200) {
        students.value = (response.data as List)
            .map((json) => StudentClassModel.fromJson(json))
            .toList();
      }
    } on DioException {
      errorMessage.value = 'Không thể tải danh sách học sinh.';
    } finally {
      isLoading.value = false;
    }
  }
}
