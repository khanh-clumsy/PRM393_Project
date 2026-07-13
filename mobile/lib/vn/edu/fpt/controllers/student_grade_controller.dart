import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../models/academic_year_model.dart';
import '../models/grade_model.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';

class StudentGradeController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final RxnInt targetStudentId = RxnInt();
  final RxString targetStudentName = ''.obs;
  final RxList<Map<String, dynamic>> linkedStudents = <Map<String, dynamic>>[].obs;

  var academicYears = <AcademicYearModel>[].obs;
  var selectedYearId = RxnInt();

  var transcript = Rxn<YearlyTranscriptModel>();
  var selectedSemesterIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      isLoading(true);
      errorMessage('');
      final role = await LocalStorage.getRole();
      final userIdStr = await LocalStorage.getUserId();
      if (userIdStr == null) {
        errorMessage('Không tìm thấy thông tin người dùng.');
        return;
      }
      final userId = int.parse(userIdStr);
      if (role?.toLowerCase() == 'parent') {
        await _resolveFromParent(userId);
      } else {
        targetStudentId.value = userId;
        await _fetchStudentName(userId);
      }
      await _fetchAcademicYears();
    } catch (e) {
      errorMessage('Lỗi khi khởi tạo: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _resolveFromParent(int parentId) async {
    final res = await ApiClient.instance.get('/api/parentstudent/dashboard/$parentId');
    if (res.statusCode == 200 && res.data['children'] is List) {
      final list = res.data['children'] as List;
      if (list.isEmpty) {
        errorMessage('Chưa có học sinh được liên kết.');
        return;
      }
      linkedStudents.value = list.map<Map<String, dynamic>>((e) => {
        'studentId': e['studentId'],
        'studentName': e['studentName'] ?? 'Học sinh',
      }).toList();
      final first = linkedStudents.first;
      targetStudentId.value = first['studentId'];
      targetStudentName.value = first['studentName'] ?? '';
    }
  }

  Future<void> _fetchStudentName(int studentId) async {
    try {
      final res = await ApiClient.instance.get('/api/user/$studentId');
      if (res.statusCode == 200) {
        targetStudentName.value = res.data['fullName'] ?? '';
      }
    } catch (_) {}
  }

  Future<void> switchToStudent(int studentId, String studentName) async {
    if (targetStudentId.value == studentId) return;
    targetStudentId.value = studentId;
    targetStudentName.value = studentName;
    selectedSemesterIndex.value = 0;
    await fetchGrades();
  }

  Future<void> _fetchAcademicYears() async {
    try {
      errorMessage('');
      final response = await ApiClient.instance.get('/api/academicyear');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        academicYears.value = AcademicYearModel.sortedChronologically(
          data.map((json) => AcademicYearModel.fromJson(json)),
        );
        if (academicYears.isNotEmpty) {
          selectedYearId.value = AcademicYearModel.preferredDefaultId(academicYears);
          await fetchGrades();
        }
      }
    } on DioException catch (e) {
      errorMessage('Lỗi khi tải năm học: ${e.message}');
    }
  }

  Future<void> fetchGrades() async {
    if (selectedYearId.value == null || targetStudentId.value == null) return;

    try {
      isLoading(true);
      errorMessage('');
      final response = await ApiClient.instance.get(
        '/api/grade/yearly-transcript/${targetStudentId.value}',
        queryParameters: {'academicYearId': selectedYearId.value},
      );
      if (response.statusCode == 200) {
        transcript.value = YearlyTranscriptModel.fromJson(response.data);
        selectedSemesterIndex.value = 0;
      }
    } on DioException catch (e) {
      errorMessage('Lỗi tải điểm: ${e.message}');
    } finally {
      isLoading(false);
    }
  }

  void onYearChanged(int? yearId) {
    if (yearId != null && yearId != selectedYearId.value) {
      selectedYearId.value = yearId;
      fetchGrades();
    }
  }
}
