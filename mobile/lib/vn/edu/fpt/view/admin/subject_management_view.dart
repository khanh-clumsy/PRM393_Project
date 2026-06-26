import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/subject_controller.dart';
import '../../models/subject_model.dart';

class SubjectManagementView extends StatelessWidget {
  const SubjectManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubjectController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Quản lý Môn học', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)));
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value, style: const TextStyle(color: Colors.redAccent)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchSubjects,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (controller.subjects.isEmpty) {
          return const Center(child: Text('Chưa có dữ liệu môn học.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.subjects.length,
          itemBuilder: (context, index) {
            final sub = controller.subjects[index];
            return Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: sub.isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  child: Icon(
                    sub.isActive ? Icons.check_circle : Icons.cancel,
                    color: sub.isActive ? Colors.green : Colors.red,
                  ),
                ),
                title: Text('${sub.subjectCode} - ${sub.subjectName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _showFormDialog(context, controller, subject: sub),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _showDeleteConfirm(context, controller, sub),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context, controller),
        backgroundColor: const Color(0xFFE65100),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFormDialog(BuildContext context, SubjectController controller, {SubjectModel? subject}) {
    final isEditing = subject != null;
    final codeController = TextEditingController(text: subject?.subjectCode ?? '');
    final nameController = TextEditingController(text: subject?.subjectName ?? '');
    bool isActive = subject?.isActive ?? true;

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(isEditing ? 'Sửa Môn Học' : 'Thêm Môn Học', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Mã môn (VD: PRM393)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên môn', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text("Đang hoạt động"),
                  value: isActive,
                  onChanged: (val) {
                    setState(() {
                      isActive = val ?? false;
                    });
                  },
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE65100), foregroundColor: Colors.white),
              onPressed: () {
                final code = codeController.text.trim();
                final name = nameController.text.trim();
                if (code.isEmpty || name.isEmpty) {
                  Get.snackbar('Lỗi', 'Vui lòng nhập đủ thông tin', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }
                if (isEditing) {
                  controller.updateSubject(subject.subjectId, code, name, isActive);
                } else {
                  controller.createSubject(code, name, isActive);
                }
              },
              child: Text(isEditing ? 'Lưu' : 'Thêm'),
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteConfirm(BuildContext context, SubjectController controller, SubjectModel subject) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa môn học "${subject.subjectCode}" không?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              controller.deleteSubject(subject.subjectId);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
