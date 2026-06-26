import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/timetable_slot_model.dart';

class TimetableSlotController extends GetxController {
  final RxList<TimetableSlotModel> slots = <TimetableSlotModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSlots();
  }

  Future<void> fetchSlots() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await ApiClient.instance.get('/api/timetableslot');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        slots.value = data.map((json) => TimetableSlotModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      errorMessage.value = 'Lỗi kết nối: ${e.message}';
    } catch (e) {
      errorMessage.value = 'Đã xảy ra lỗi: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSlot(String name, String startTime, String endTime) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/timetableslot',
        data: {
          'slotName': name,
          'startTime': startTime,
          'endTime': endTime,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back();
        Get.snackbar('Thành công', 'Thêm ca học mới thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchSlots();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm ca học', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> updateSlot(int id, String? name, String? startTime, String? endTime) async {
    try {
      final response = await ApiClient.instance.put(
        '/api/timetableslot/$id',
        data: {
          'slotName': name,
          'startTime': startTime,
          'endTime': endTime,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back();
        Get.snackbar('Thành công', 'Cập nhật ca học thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchSlots();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật ca học', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> deleteSlot(int id) async {
    try {
      final response = await ApiClient.instance.delete('/api/timetableslot/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back();
        Get.snackbar('Thành công', 'Xóa ca học thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchSlots();
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Lỗi', 'Không thể xóa do ràng buộc dữ liệu', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
