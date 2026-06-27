import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/academic_rank_model.dart';

class AcademicRankController extends GetxController {
  final RxList<AcademicRankModel> ranks = <AcademicRankModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRanks();
  }

  Future<void> fetchRanks() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await ApiClient.instance.get('/api/academicrank');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        ranks.value = data.map((json) => AcademicRankModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      print('DioException: $e');
      errorMessage.value = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng và thử lại.';
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createRank(String name, double minScore, double maxScore) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/academicrank',
        data: {
          'rankName': name,
          'minScore': minScore,
          'maxScore': maxScore,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back();
        Get.snackbar('Thành công', 'Thêm xếp loại thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchRanks();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm xếp loại', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> updateRank(int id, String? name, double? minScore, double? maxScore) async {
    try {
      final response = await ApiClient.instance.put(
        '/api/academicrank/$id',
        data: {
          'rankName': name,
          'minScore': minScore,
          'maxScore': maxScore,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back();
        Get.snackbar('Thành công', 'Cập nhật xếp loại thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchRanks();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật xếp loại', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> deleteRank(int id) async {
    try {
      final response = await ApiClient.instance.delete('/api/academicrank/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back();
        Get.snackbar('Thành công', 'Xóa xếp loại thành công', backgroundColor: Colors.green, colorText: Colors.white);
        fetchRanks();
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Lỗi', 'Không thể xóa do ràng buộc dữ liệu', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
