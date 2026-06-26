import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';
import '../models/announcement_model.dart';
import '../models/class_model.dart';

class AnnouncementController extends GetxController {
  final RxList<AnnouncementModel> announcements = <AnnouncementModel>[].obs;
  final RxList<ClassModel> classes = <ClassModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

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
        _fetchAnnouncements(),
        _fetchClasses(),
      ]);
    } catch (e) {
      errorMessage.value = 'Đã xảy ra lỗi khi tải dữ liệu.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAnnouncements() async {
    try {
      isLoading.value = true;
      await _fetchAnnouncements();
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchAnnouncements() async {
    final response = await ApiClient.instance.get('/api/announcement');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      announcements.value = data.map((json) => AnnouncementModel.fromJson(json)).toList();
    }
  }

  Future<void> _fetchClasses() async {
    final response = await ApiClient.instance.get('/api/class');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      classes.value = data.map((json) => ClassModel.fromJson(json)).toList();
    }
  }

  Future<void> createAnnouncement(String title, String content, String type, String priority, List<int> targetClassIds) async {
    try {
      final userIdStr = await LocalStorage.getUserId();
      if (userIdStr == null) return;
      final authorId = int.parse(userIdStr);

      final response = await ApiClient.instance.post(
        '/api/announcement',
        data: {
          'authorId': authorId,
          'title': title,
          'content': content,
          'announcementType': type,
          'priority': priority,
          'targetClassIds': targetClassIds,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back();
        Get.snackbar('Thành công', 'Đăng bảng tin thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchAnnouncements();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể đăng bảng tin', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> updateAnnouncement(int id, String? title, String? content, String? priority) async {
    try {
      final response = await ApiClient.instance.put(
        '/api/announcement/$id',
        data: {
          'title': title,
          'content': content,
          'priority': priority,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back();
        Get.snackbar('Thành công', 'Cập nhật bảng tin thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchAnnouncements();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật bảng tin', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> deleteAnnouncement(int id) async {
    try {
      final response = await ApiClient.instance.delete('/api/announcement/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back();
        Get.snackbar('Thành công', 'Xóa bảng tin thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchAnnouncements();
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Lỗi', 'Không thể xóa bảng tin', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
