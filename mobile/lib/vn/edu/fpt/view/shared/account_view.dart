import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/account_controller.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller
    final controller = Get.put(AccountController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Color(0xFFE65100))),
        );
      }

      if (controller.errorMessage.value != null) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value!, style: const TextStyle(color: Colors.redAccent)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchUserData,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        appBar: AppBar(
          title: const Text('Tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(controller),
              const SizedBox(height: 24),
              _buildInfoCard(controller),
              const SizedBox(height: 32),
              _buildLogoutButton(controller),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildProfileHeader(AccountController controller) {
    final avatarUrl = controller.userData['avatarUrl'];
    final fullName = controller.userData['fullName'] ?? 'N/A';
    final roleName = controller.userData['roleName'] ?? 'N/A';

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFFFE0B2),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null 
              ? Text(
                  fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFE65100))
                )
              : null,
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              roleName.toUpperCase(),
              style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(AccountController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildInfoRow(Icons.person_outline, 'Tên đăng nhập', controller.userData['username'] ?? 'N/A'),
            const Divider(height: 1, indent: 56),
            _buildInfoRow(Icons.phone_outlined, 'Số điện thoại', controller.userData['phoneNumber'] ?? 'N/A'),
            const Divider(height: 1, indent: 56),
            _buildInfoRow(Icons.email_outlined, 'Email', controller.userData['email'] ?? 'N/A'),
            const Divider(height: 1, indent: 56),
            _buildInfoRow(Icons.calendar_today_outlined, 'Ngày sinh', controller.userData['dateOfBirth']?.toString().split('T').first ?? 'N/A'),
            const Divider(height: 1, indent: 56),
            _buildInfoRow(Icons.location_on_outlined, 'Địa chỉ', controller.userData['address'] ?? 'N/A'),
            const Divider(height: 1, indent: 56),
            _buildInfoRow(Icons.people_outline, 'Giới tính', controller.userData['gender'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AccountController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            // Confirm logout
            Get.dialog(
              AlertDialog(
                title: const Text('Xác nhận'),
                content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: () {
                      Get.back(); // close dialog
                      controller.logout();
                    },
                    child: const Text('Đăng xuất'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
