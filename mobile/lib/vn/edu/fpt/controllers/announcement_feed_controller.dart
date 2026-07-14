import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../core/network/api_client.dart';
import '../core/network/api_error_helper.dart';
import '../models/announcement_model.dart';

class AnnouncementFeedController extends GetxController {
  final RxList<AnnouncementModel> feedItems = <AnnouncementModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

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
      errorMessage.value = ApiErrorHelper.messageFrom(e, fallback: 'Khong tai duoc bang tin.');
    } finally {
      isLoading.value = false;
    }
  }
}
