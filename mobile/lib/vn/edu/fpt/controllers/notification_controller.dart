import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../core/network/api_client.dart';
import '../core/network/api_error_helper.dart';
import '../models/notification_log_model.dart';

class NotificationController extends GetxController {
  final RxList<NotificationLogModel> notifications = <NotificationLogModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await ApiClient.instance.get('/api/notificationlog/me');
      if (res.statusCode == 200) {
        final list = (res.data as List<dynamic>)
            .map((e) => NotificationLogModel.fromJson(e as Map<String, dynamic>))
            .toList();
        notifications.value = list;
        unreadCount.value = list.where((n) => !n.isRead).length;
      }
    } on DioException catch (e) {
      errorMessage.value = ApiErrorHelper.messageFrom(e, fallback: 'Khong tai duoc thong bao.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      final res = await ApiClient.instance.get('/api/notificationlog/me/unread-count');
      if (res.statusCode == 200) {
        unreadCount.value = (res.data['count'] as num).toInt();
      }
    } on DioException {
      unreadCount.value = notifications.where((n) => !n.isRead).length;
    }
  }

  Future<void> markRead(int notificationId) async {
    try {
      final res = await ApiClient.instance.put('/api/notificationlog/$notificationId/read');
      if (res.statusCode == 200) {
        final idx = notifications.indexWhere((n) => n.notificationId == notificationId);
        if (idx >= 0) {
          notifications[idx] = notifications[idx].copyWith(
            isRead: true,
            readAt: DateTime.now().toUtc().toIso8601String(),
          );
          unreadCount.value = notifications.where((n) => !n.isRead).length;
        }
      }
    } on DioException catch (e) {
      Get.snackbar('Loi', ApiErrorHelper.messageFrom(e, fallback: 'Khong danh dau duoc thong bao.'));
    }
  }

  Future<void> markAllRead() async {
    try {
      final res = await ApiClient.instance.put('/api/notificationlog/me/read-all');
      if (res.statusCode == 204 || res.statusCode == 200) {
        notifications.value = notifications
            .map((n) => n.copyWith(
                  isRead: true,
                  readAt: n.readAt ?? DateTime.now().toUtc().toIso8601String(),
                ))
            .toList();
        unreadCount.value = 0;
      }
    } on DioException catch (e) {
      Get.snackbar('Loi', ApiErrorHelper.messageFrom(e, fallback: 'Khong danh dau het duoc thong bao.'));
    }
  }
}
