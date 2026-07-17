import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/app_button.dart';
import '../../controllers/auth_controller.dart';
import '../../core/dev/dev_login_accounts.dart';

/// Panel đăng nhập nhanh theo role — chỉ compile/hiện khi `kDebugMode`.
class DevLoginPanel extends StatelessWidget {
  final AuthController authController;
  final void Function(String phone, String password) onPickAccount;

  const DevLoginPanel({
    super.key,
    required this.authController,
    required this.onPickAccount,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD8B8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFE65100).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 18,
                  color: Color(0xFFE65100),
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Đăng nhập nhanh (dev)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'MK: $devLoginPassword · chỉ hiện khi chạy debug',
            style: TextStyle(
              fontSize: 11,
              height: 1.35,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            final isLoading = authController.isLoading.value;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kDevLoginAccounts.map((account) {
                return AppButton(
                  label: account.label,
                  onPressed: isLoading
                      ? null
                      : () => onPickAccount(account.phoneNumber, account.password),
                  variant: AppButtonVariant.outlined,
                  height: 34,
                  borderRadius: 10,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
