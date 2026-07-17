import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../core/network/api_error_helper.dart';

// Điều khiển luồng quên mật khẩu: gửi OTP và đặt mật khẩu mới.
class ForgotPasswordController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final infoMessage = ''.obs;
  final codeSent = false.obs;
  final email = ''.obs;

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String? validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Vui lòng nhập email.';
    if (!_emailRegex.hasMatch(trimmed)) return 'Email không hợp lệ.';
    return null;
  }

  String? validateReset(String code, String password, String confirmPassword) {
    final trimmedCode = code.trim();
    if (trimmedCode.length != 6 || int.tryParse(trimmedCode) == null) {
      return 'Mã xác nhận gồm 6 chữ số.';
    }
    if (password.length < 8) return 'Mật khẩu tối thiểu 8 ký tự.';
    if (password != confirmPassword) return 'Mật khẩu nhập lại không khớp.';
    return null;
  }

  Future<void> sendCode(String emailInput) async {
    final validation = validateEmail(emailInput);
    if (validation != null) {
      errorMessage.value = validation;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    infoMessage.value = '';
    try {
      final normalizedEmail = emailInput.trim();
      await ApiClient.instance.post(
        '/api/auth/forgot-password',
        data: {'email': normalizedEmail},
      );
      email.value = normalizedEmail;
      codeSent.value = true;
      infoMessage.value = 'Nếu email hợp lệ, mã đặt lại mật khẩu đã được gửi.';
    } on DioException catch (e) {
      errorMessage.value = ApiErrorHelper.messageFrom(
        e,
        fallback: 'Không thể gửi mã lúc này. Vui lòng thử lại.',
      );
    } catch (_) {
      errorMessage.value = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword(
    String code,
    String password,
    String confirmPassword,
  ) async {
    final validation = validateReset(code, password, confirmPassword);
    if (validation != null) {
      errorMessage.value = validation;
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      await ApiClient.instance.post(
        '/api/auth/reset-password',
        data: {
          'email': email.value,
          'code': code.trim(),
          'newPassword': password,
        },
      );
      return true;
    } on DioException catch (e) {
      errorMessage.value = ApiErrorHelper.messageFrom(
        e,
        fallback: 'Mã xác nhận không hợp lệ hoặc đã hết hạn.',
      );
      return false;
    } catch (_) {
      errorMessage.value = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
