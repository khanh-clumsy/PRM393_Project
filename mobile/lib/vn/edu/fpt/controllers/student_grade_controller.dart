import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../models/academic_year_model.dart';
import '../models/grade_model.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';

class StudentGradeController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var academicYears = <AcademicYearModel>[].obs;
  var selectedYearId = RxnInt();

  var transcript = Rxn<YearlyTranscriptModel>();
  var selectedSemesterIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchAcademicYears();
  }

  Future<void> _fetchAcademicYears() async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await ApiClient.instance.get('/api/academicyear');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        academicYears.value = data.map((json) => AcademicYearModel.fromJson(json)).toList();
        
        if (academicYears.isNotEmpty) {
          final activeYear = academicYears.firstWhereOrNull((y) => y.isActive);
          selectedYearId.value = activeYear?.academicYearId ?? academicYears.first.academicYearId;
          fetchGrades();
        }
      }
    } on DioException catch (e) {
      errorMessage('Lỗi khi tải năm học: ${e.message}');
    } catch (e) {
      errorMessage('Lỗi không xác định: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchGrades() async {
    if (selectedYearId.value == null) return;
    
    final studentId = int.tryParse(await LocalStorage.getUserId() ?? '');
    if (studentId == null) {
      errorMessage('Không tìm thấy thông tin học sinh.');
      return;
    }

    try {
      isLoading(true);
      errorMessage('');
      final response = await ApiClient.instance.get(
        '/api/grade/yearly-transcript/$studentId',
        queryParameters: {'academicYearId': selectedYearId.value},
      );
      if (response.statusCode == 200) {
        transcript.value = YearlyTranscriptModel.fromJson(response.data);
      }
    } on DioException catch (e) {
      errorMessage('Lỗi tải điểm: ${e.message}');
    } catch (e) {
      errorMessage('Lỗi không xác định: $e');
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
