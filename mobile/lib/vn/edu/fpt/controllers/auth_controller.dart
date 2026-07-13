import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../core/network/api_error_helper.dart';
import '../core/submit/submit_guard_mixin.dart';
import '../core/storage/local_storage.dart';
import '../models/auth_model.dart';

class AuthController extends GetxController with SubmitGuardMixin {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> login(String phoneNumber, String password) async {
    if (phoneNumber.trim().isEmpty || password.trim().isEmpty) {
      errorMessage.value = 'Vui lòng nhập đầy đủ thông tin.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiClient.instance.post(
        '/api/auth/login',
        data: {'phoneNumber': phoneNumber.trim(), 'password': password},
      );

      if (response.statusCode == 200) {
        final auth = AuthModel.fromJson(response.data);

        await LocalStorage.saveTokens(
          accessToken: auth.accessToken,
          refreshToken: auth.refreshToken,
        );
        await LocalStorage.saveRole(auth.roleName);
        await LocalStorage.saveUserId(auth.userId.toString());
        await LocalStorage.saveDepartmentId(auth.departmentId?.toString());

        _navigateByRole(auth.roleName);
      }
    } on DioException catch (e) {
      print(
        'DIO ERROR: type=${e.type} | msg=${e.message} | status=${e.response?.statusCode} | data=${e.response?.data}',
      );
      errorMessage.value = ApiErrorHelper.messageFrom(
        e,
        fallback: switch (e.response?.statusCode) {
          401 || 400 => 'Tên đăng nhập hoặc mật khẩu không đúng.',
          403 => 'Tài khoản đã bị khóa. Vui lòng liên hệ quản trị viên.',
          _ => 'Không thể kết nối đến máy chủ. Vui lòng thử lại.',
        },
      );
    } catch (e) {
      print('UNKNOWN ERROR: $e');
      errorMessage.value = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await runSubmitting(() async {
      try {
        await ApiClient.instance.post('/api/auth/logout');
      } catch (_) {}
      await LocalStorage.clearAll();
      Get.offAllNamed('/login');
    });
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
