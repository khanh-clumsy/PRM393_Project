import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../core/network/api_client.dart';
import '../core/network/api_error_helper.dart';
import '../core/storage/local_storage.dart';
import '../core/submit/submit_guard_mixin.dart';
import '../models/student_request_model.dart';

class LeaveRequestController extends GetxController with SubmitGuardMixin {
  final RxList<StudentRequestModel> requests = <StudentRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  int? _studentId;
  int? _requestedBy;

  Future<void> init({required int studentId, required int requestedBy}) async {
    _studentId = studentId;
    _requestedBy = requestedBy;
    await fetchRequests();
  }

  Future<void> initForCurrentStudent() async {
    final userIdStr = await LocalStorage.getUserId();
    final id = int.tryParse(userIdStr ?? '');
    if (id == null) {
      errorMessage.value = 'Khong tim thay tai khoan.';
      return;
    }
    await init(studentId: id, requestedBy: id);
  }

  Future<void> fetchRequests() async {
    if (_studentId == null) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await ApiClient.instance.get('/api/studentrequest/by-student/$_studentId');
      if (res.statusCode == 200) {
        requests.value = (res.data as List<dynamic>)
            .map((e) => StudentRequestModel.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } on DioException catch (e) {
      errorMessage.value = ApiErrorHelper.messageFrom(e, fallback: 'Khong tai duoc don xin nghi.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitRequest({
    required DateTime leaveDate,
    required String reason,
    String? attachmentUrl,
  }) async {
    if (_studentId == null || _requestedBy == null) return false;
    var ok = false;
    await runSubmitting(() async {
      try {
        final cleanAttachment = attachmentUrl?.trim();
        final res = await ApiClient.instance.post('/api/studentrequest', data: {
          'studentId': _studentId,
          'requestedBy': _requestedBy,
          'leaveDate': DateFormat('yyyy-MM-dd').format(leaveDate),
          'reason': reason.trim(),
          'attachmentUrl': cleanAttachment == null || cleanAttachment.isEmpty ? null : cleanAttachment,
        });
        if (res.statusCode == 200 || res.statusCode == 201) {
          ok = true;
          await fetchRequests();
        }
      } on DioException catch (e) {
        Get.snackbar('Loi', ApiErrorHelper.messageFrom(e, fallback: 'Gui don that bai.'));
      }
    });
    return ok;
  }
}
