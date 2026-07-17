import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/forgot_password_controller.dart';
import '../../widgets/app_button.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  static const Color _primary = Color(0xFFE65100);
  static const Color _ink = Color(0xFF1F2937);
  static const Color _muted = Color(0xFF6B7280);

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  late final ForgotPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ForgotPasswordController());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    Get.delete<ForgotPasswordController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            20,
            22,
            20,
            22 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Obx(() {
                final codeSent = _controller.codeSent.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      codeSent ? 'Đặt mật khẩu mới' : 'Nhận mã xác nhận',
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      codeSent
                          ? 'Nhập mã gồm 6 chữ số đã gửi tới ${_controller.email.value}.'
                          : 'Nhập email tài khoản để nhận mã đặt lại mật khẩu.',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (codeSent) _buildResetStep() else _buildEmailStep(),
                    const SizedBox(height: 16),
                    _buildMessages(),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildField(
          controller: _emailController,
          label: 'Email',
          hintText: 'student@fschool.edu.vn',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        AppButton.reactive(
          isLoading: _controller.isLoading,
          label: 'Gửi mã',
          loadingLabel: 'Đang gửi...',
          icon: Icons.mark_email_read_outlined,
          fullWidth: true,
          height: 52,
          borderRadius: 16,
          onPressed: () => _controller.sendCode(_emailController.text),
        ),
      ],
    );
  }

  Widget _buildResetStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildField(
          controller: _codeController,
          label: 'Mã xác nhận',
          hintText: '123456',
          icon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 14),
        _buildField(
          controller: _passwordController,
          label: 'Mật khẩu mới',
          hintText: 'Tối thiểu 8 ký tự',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            tooltip: _obscurePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 14),
        _buildField(
          controller: _confirmController,
          label: 'Nhập lại mật khẩu',
          hintText: 'Nhập lại mật khẩu mới',
          icon: Icons.lock_reset_rounded,
          obscureText: _obscureConfirm,
          suffixIcon: IconButton(
            tooltip: _obscureConfirm ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
            icon: Icon(
              _obscureConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),
        const SizedBox(height: 18),
        AppButton.reactive(
          isLoading: _controller.isLoading,
          label: 'Đặt lại mật khẩu',
          loadingLabel: 'Đang xử lý...',
          icon: Icons.check_circle_outline_rounded,
          fullWidth: true,
          height: 52,
          borderRadius: 16,
          onPressed: () async {
            final ok = await _controller.resetPassword(
              _codeController.text,
              _passwordController.text,
              _confirmController.text,
            );
            if (ok) {
              Get.snackbar('Thành công', 'Đặt lại mật khẩu thành công.');
              Get.offAllNamed('/login');
            }
          },
        ),
      ],
    );
  }

  Widget _buildMessages() {
    if (_controller.errorMessage.value.isEmpty &&
        _controller.infoMessage.value.isEmpty) {
      return const SizedBox.shrink();
    }

    final isError = _controller.errorMessage.value.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? const Color(0xFFFFCDD2) : const Color(0xFFC8E6C9),
        ),
      ),
      child: Text(
        isError
            ? _controller.errorMessage.value
            : _controller.infoMessage.value,
        style: TextStyle(
          color: isError ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
          fontSize: 13,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      style: const TextStyle(
        color: _ink,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: _primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFFFFBF7),
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFD8B8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primary, width: 1.6),
        ),
      ),
    );
  }
}
