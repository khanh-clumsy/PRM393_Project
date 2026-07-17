import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../core/network/api_client.dart';
import '../core/network/api_error_helper.dart';
import '../models/announcement_model.dart';

class AnnouncementFeedController extends GetxController {
  final RxList<AnnouncementModel> feedItems = <AnnouncementModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  static const _feedTags = ['notifications_feed', 'student_home_feed'];

  int get unreadCount => feedItems.where((a) => !a.isRead).length;

  bool isUnread(int announcementId) {
    final item = feedItems.firstWhereOrNull((a) => a.announcementId == announcementId);
    return item != null && !item.isRead;
  }

  Future<void> loadFeed() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await ApiClient.instance.get('/api/announcement/my-feed');
      if (res.statusCode == 200) {
        feedItems.value = (res.data as List<dynamic>)
            .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (e) {
      errorMessage.value = ApiErrorHelper.messageFrom(e, fallback: 'Không tải được bảng tin.');
    } finally {
      isLoading.value = false;
    }
  }

  void _setReadLocal(int announcementId, bool isRead) {
    final idx = feedItems.indexWhere((a) => a.announcementId == announcementId);
    if (idx >= 0) {
      feedItems[idx] = feedItems[idx].copyWith(isRead: isRead);
      feedItems.refresh();
    }
  }

  /// Đồng bộ đã đọc trên mọi instance feed (home + list thông báo).
  static void syncReadAcrossFeeds(int announcementId, {bool isRead = true}) {
    for (final tag in _feedTags) {
      if (!Get.isRegistered<AnnouncementFeedController>(tag: tag)) continue;
      Get.find<AnnouncementFeedController>(tag: tag)._setReadLocal(announcementId, isRead);
    }
  }

  static void syncAllReadAcrossFeeds() {
    for (final tag in _feedTags) {
      if (!Get.isRegistered<AnnouncementFeedController>(tag: tag)) continue;
      final c = Get.find<AnnouncementFeedController>(tag: tag);
      c.feedItems.value = c.feedItems.map((a) => a.copyWith(isRead: true)).toList();
    }
  }

  /// Luôn gọi API (không phụ thuộc item có trong list local hay không).
  Future<bool> markRead(int announcementId) async {
    final local = feedItems.firstWhereOrNull((a) => a.announcementId == announcementId);
    if (local?.isRead == true) return true;

    syncReadAcrossFeeds(announcementId, isRead: true);
    final ok = await markReadRemote(announcementId);
    if (!ok) syncReadAcrossFeeds(announcementId, isRead: false);
    return ok;
  }

  static Future<bool> markReadRemote(int announcementId) async {
    try {
      final res = await ApiClient.instance.put(
        '/api/announcement/$announcementId/read',
        data: <String, dynamic>{},
      );
      if (res.statusCode == 200 || res.statusCode == 204) {
        syncReadAcrossFeeds(announcementId, isRead: true);
        return true;
      }
      return false;
    } on DioException catch (e) {
      Get.snackbar('Lỗi', ApiErrorHelper.messageFrom(e, fallback: 'Không đánh dấu được đã đọc.'));
      return false;
    }
  }

  Future<void> markAllRead() async {
    if (unreadCount == 0) return;
    final previousByTag = <String, List<AnnouncementModel>>{};
    for (final tag in _feedTags) {
      if (!Get.isRegistered<AnnouncementFeedController>(tag: tag)) continue;
      previousByTag[tag] = Get.find<AnnouncementFeedController>(tag: tag)
          .feedItems
          .map((a) => a.copyWith())
          .toList();
    }
    syncAllReadAcrossFeeds();

    try {
      await ApiClient.instance.put(
        '/api/announcement/me/read-all',
        data: <String, dynamic>{},
      );
    } on DioException catch (e) {
      for (final entry in previousByTag.entries) {
        if (!Get.isRegistered<AnnouncementFeedController>(tag: entry.key)) continue;
        Get.find<AnnouncementFeedController>(tag: entry.key).feedItems.value = entry.value;
      }
      Get.snackbar('Lỗi', ApiErrorHelper.messageFrom(e, fallback: 'Không đánh dấu được đã đọc.'));
    }
  }
}
