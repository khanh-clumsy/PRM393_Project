import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/head_dept_controller.dart';

class HeadDeptTeachersView extends StatelessWidget {
  const HeadDeptTeachersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HeadDeptTeachersController());
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Giáo viên tổ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)));
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }
        if (controller.teachers.isEmpty) {
          return const Center(child: Text('Chưa có giáo viên trong tổ.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.teachers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final t = controller.teachers[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFFFF3E0),
                  child: Text(t.fullName.isNotEmpty ? t.fullName[0].toUpperCase() : '?'),
                ),
                title: Text(t.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(t.phoneNumber ?? t.username),
              ),
            );
          },
        );
      }),
    );
  }
}
