import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';
import '../models/auth_model.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> login(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      errorMessage.value = 'Vui lòng nhập đầy đủ thông tin.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiClient.instance.post(
        '/api/auth/login',
        data: {'username': username.trim(), 'password': password},
      );

      if (response.statusCode == 200) {
        final auth = AuthModel.fromJson(response.data);

        await LocalStorage.saveTokens(
          accessToken: auth.accessToken,
          refreshToken: auth.refreshToken,
        );
        await LocalStorage.saveRole(auth.roleName);
        await LocalStorage.saveUserId(auth.userId.toString());

        _navigateByRole(auth.roleName);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        errorMessage.value = 'Tên đăng nhập hoặc mật khẩu không đúng.';
      } else {
        errorMessage.value = 'Không thể kết nối đến máy chủ. Vui lòng thử lại.';
      }
    } catch (_) {
      errorMessage.value = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post('/api/auth/logout');
    } catch (_) {}
    await LocalStorage.clearAll();
    Get.offAllNamed('/login');
  }

  // Kiểm tra token khi khởi động app
  Future<String?> getInitialRoute() async {
    final token = await LocalStorage.getAccessToken();
    if (token == null) return '/login';

    final role = await LocalStorage.getRole();
    return _routeForRole(role ?? '');
  }

  void _navigateByRole(String roleName) {
    Get.offAllNamed(_routeForRole(roleName));
  }

  String _routeForRole(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'student':
        return '/student';
      case 'teacher':
        return '/teacher';
      case 'admin':
        return '/admin';
      case 'headofdept':
        return '/head';
      case 'parent':
        return '/parent';
      default:
        return '/login';
    }
  }
}