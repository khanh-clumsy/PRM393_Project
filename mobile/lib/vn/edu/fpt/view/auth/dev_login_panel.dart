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
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report_outlined, size: 18, color: Colors.grey.shade700),
              const SizedBox(width: 6),
              Text(
                'Đăng nhập nhanh (dev)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'MK: $devLoginPassword · chỉ hiện khi chạy debug',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
                  onPressed: isLoading ? null : () => onPickAccount(account.phoneNumber, account.password),
                  variant: AppButtonVariant.outlined,
                  height: 36,
                  borderRadius: 8,
                  labelStyle: const TextStyle(fontSize: 13),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
