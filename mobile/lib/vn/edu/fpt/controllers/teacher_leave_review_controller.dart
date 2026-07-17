import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../core/network/api_client.dart';
import '../core/network/api_error_helper.dart';
import '../core/storage/local_storage.dart';
import '../core/submit/submit_guard_mixin.dart';
import '../models/student_request_model.dart';

class TeacherLeaveReviewController extends GetxController with SubmitGuardMixin {
  final RxList<StudentRequestModel> pending = <StudentRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPending();
  }

  Future<void> fetchPending() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await ApiClient.instance.get('/api/studentrequest/pending/for-teacher');
      if (res.statusCode == 200) {
        pending.value = (res.data as List<dynamic>)
            .map((e) => StudentRequestModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (e) {
      errorMessage.value = ApiErrorHelper.messageFrom(e, fallback: 'Không tải được đơn chờ duyệt.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> review(int requestId, String status, {String? note}) async {
    final reviewerStr = await LocalStorage.getUserId();
    final reviewerId = int.tryParse(reviewerStr ?? '');
    if (reviewerId == null) return;
    await runSubmitting(() async {
      try {
        await ApiClient.instance.put('/api/studentrequest/$requestId/review', data: {
          'status': status,
          'reviewedBy': reviewerId,
          'reviewNote': note,
        });
        await fetchPending();
      } on DioException catch (e) {
        Get.snackbar('Lỗi', ApiErrorHelper.messageFrom(e, fallback: 'Không cập nhật được đơn.'));
      }
    });
  }
}
