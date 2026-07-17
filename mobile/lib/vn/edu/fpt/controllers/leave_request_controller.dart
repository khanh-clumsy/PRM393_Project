import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../core/network/api_client.dart';
import '../core/network/api_error_helper.dart';
import '../core/storage/local_storage.dart';
import '../core/submit/submit_guard_mixin.dart';
import '../models/student_request_model.dart';
import 'timetable_controller.dart';

class LeaveRequestController extends GetxController with SubmitGuardMixin {
  final RxList<StudentRequestModel> requests = <StudentRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxnInt targetStudentId = RxnInt();
  final RxString targetStudentName = ''.obs;
  final RxList<Map<String, dynamic>> linkedStudents = <Map<String, dynamic>>[].obs;

  int? _requestedBy;

  /// Khởi tạo theo role (HS tự xem / PH chọn con).
  Future<void> bootstrap({int? studentId, int? requestedBy}) async {
    if (studentId != null && requestedBy != null) {
      await init(studentId: studentId, requestedBy: requestedBy);
      return;
    }

    final userIdStr = await LocalStorage.getUserId();
    final id = int.tryParse(userIdStr ?? '');
    if (id == null) {
      errorMessage.value = 'Không tìm thấy tài khoản.';
      return;
    }

    final role = (await LocalStorage.getRole())?.toLowerCase();
    if (role == 'parent') {
      await _initForParent(id);
    } else {
      await init(studentId: id, requestedBy: id);
    }
  }

  Future<void> init({required int studentId, required int requestedBy}) async {
    _requestedBy = requestedBy;
    targetStudentId.value = studentId;
    linkedStudents.clear();
    await fetchRequests();
  }

  Future<void> _initForParent(int parentId) async {
    _requestedBy = parentId;
    try {
      final res = await ApiClient.instance.get('/api/parentstudent/dashboard/$parentId');
      if (res.statusCode != 200 || res.data['children'] is! List) {
        errorMessage.value = 'Không tải được danh sách con.';
        return;
      }
      final list = res.data['children'] as List;
      if (list.isEmpty) {
        errorMessage.value = 'Chưa có học sinh được liên kết.';
        return;
      }
      linkedStudents.value = list
          .map<Map<String, dynamic>>((e) => {
                'studentId': e['studentId'],
                'studentName': e['studentName'] ?? 'Học sinh',
              })
          .toList();

      // Ưu tiên con đang chọn trên trang chủ PH (nếu có).
      int? preferId;
      if (Get.isRegistered<TimetableController>()) {
        preferId = Get.find<TimetableController>().targetStudentId.value;
      }
      final preferred = linkedStudents.firstWhereOrNull((s) => s['studentId'] == preferId);
      final initial = preferred ?? linkedStudents.first;
      targetStudentId.value = initial['studentId'] as int;
      targetStudentName.value = initial['studentName'] as String? ?? '';
      await fetchRequests();
    } on DioException catch (e) {
      errorMessage.value = ApiErrorHelper.messageFrom(e, fallback: 'Không tải được danh sách con.');
    }
  }

  Future<void> switchToStudent(int studentId, String studentName) async {
    if (targetStudentId.value == studentId) return;
    targetStudentId.value = studentId;
    targetStudentName.value = studentName;
    if (Get.isRegistered<TimetableController>()) {
      await Get.find<TimetableController>().switchToStudent(studentId);
    }
    await fetchRequests();
  }

  Future<void> fetchRequests() async {
    final studentId = targetStudentId.value;
    if (studentId == null) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await ApiClient.instance.get('/api/studentrequest/by-student/$studentId');
      if (res.statusCode == 200) {
        requests.value = (res.data as List<dynamic>)
            .map((e) => StudentRequestModel.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } on DioException catch (e) {
      errorMessage.value = ApiErrorHelper.messageFrom(e, fallback: 'Không tải được đơn xin nghỉ.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitRequest({
    required DateTime leaveDate,
    required String reason,
    String? attachmentUrl,
  }) async {
    final studentId = targetStudentId.value;
    if (studentId == null || _requestedBy == null) return false;
    var ok = false;
    await runSubmitting(() async {
      try {
        final cleanAttachment = attachmentUrl?.trim();
        final res = await ApiClient.instance.post('/api/studentrequest', data: {
          'studentId': studentId,
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
        Get.snackbar('Lỗi', ApiErrorHelper.messageFrom(e, fallback: 'Gửi đơn thất bại.'));
      }
    });
    return ok;
  }

  /// Chỉ hủy được đơn đang chờ duyệt (Pending).
  Future<bool> cancelRequest(int requestId) async {
    var ok = false;
    await runSubmitting(() async {
      try {
        final res = await ApiClient.instance.delete('/api/studentrequest/$requestId');
        if (res.statusCode == 200 || res.statusCode == 204) {
          ok = true;
          await fetchRequests();
        }
      } on DioException catch (e) {
        Get.snackbar('Lỗi', ApiErrorHelper.messageFrom(e, fallback: 'Không hủy được đơn.'));
      }
    });
    return ok;
  }
}
