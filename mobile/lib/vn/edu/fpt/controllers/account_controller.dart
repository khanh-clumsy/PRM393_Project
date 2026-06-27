import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';
import 'auth_controller.dart';

class AccountController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final userId = await LocalStorage.getUserId();
      if (userId == null) {
        errorMessage.value = "Không tìm thấy ID người dùng.";
        isLoading.value = false;
        return;
      }

      final response = await ApiClient.instance.get('/api/user/$userId');
      if (response.statusCode == 200) {
        userData.value = response.data;
        isLoading.value = false;
      }
    } on DioException catch (e) {
      print('DioException: $e');
      errorMessage.value = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng và thử lại.';
      isLoading.value = false;
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.';
      isLoading.value = false;
    }
  }

  void logout() {
    Get.find<AuthController>().logout();
  }
}
