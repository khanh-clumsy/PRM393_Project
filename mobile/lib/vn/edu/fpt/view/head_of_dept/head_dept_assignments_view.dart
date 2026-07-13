import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/head_dept_controller.dart';

class HeadDeptAssignmentsView extends StatelessWidget {
  const HeadDeptAssignmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HeadDeptAssignmentsController());
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Phân công tổ', style: TextStyle(fontWeight: FontWeight.bold)),
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
        if (controller.assignments.isEmpty) {
          return const Center(child: Text('Chưa có phân công trong tổ.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.assignments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final a = controller.assignments[index];
            return Card(
              child: ListTile(
                title: Text(a.subjectName ?? 'Môn học', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Lớp: ${a.className ?? a.classId} • Học kỳ: ${a.semesterId}'),
              ),
            );
          },
        );
      }),
    );
  }
}
