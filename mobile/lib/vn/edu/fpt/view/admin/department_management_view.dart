import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/department_controller.dart';
import '../../models/department_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog_actions.dart';

class DepartmentManagementView extends StatelessWidget {
  const DepartmentManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DepartmentController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Quản lý Khoa / Phòng ban', style: TextStyle(fontWeight: FontWeight.bold)),
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
                AppButton.retry(onPressed: controller.fetchDepartments),
              ],
            ),
          );
        }

        if (controller.departments.isEmpty) {
          return const Center(child: Text('Chưa có dữ liệu phòng ban.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.departments.length,
          itemBuilder: (context, index) {
            final dept = controller.departments[index];
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
                  backgroundColor: const Color(0xFFFFF3E0),
                  child: Text(
                    dept.departmentName.isNotEmpty ? dept.departmentName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(dept.departmentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(dept.description ?? 'Không có mô tả', maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _showFormDialog(context, controller, department: dept),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _showDeleteConfirm(context, controller, dept),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: AppFab.add(
        onPressed: () => _showFormDialog(context, controller),
      ),
    );
  }

  void _showFormDialog(BuildContext context, DepartmentController controller, {DepartmentModel? department}) {
    final isEditing = department != null;
    final nameController = TextEditingController(text: department?.departmentName ?? '');
    final descController = TextEditingController(text: department?.description ?? '');

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(isEditing ? 'Sửa Phòng Ban' : 'Thêm Phòng Ban', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên phòng ban *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          AppDialogActions.reactive(
            isSubmitting: controller.isSubmitting,
            onCancel: () => Get.back(),
            labels: isEditing ? AppDialogLabels.save : AppDialogLabels.add,
            onSubmit: () {
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              if (name.isEmpty) {
                Get.snackbar('Lỗi', 'Tên phòng ban không được để trống', backgroundColor: Colors.redAccent, colorText: Colors.white);
                return;
              }
              if (isEditing) {
                controller.updateDepartment(department.departmentId, name, desc.isEmpty ? null : desc);
              } else {
                controller.createDepartment(name, desc.isEmpty ? null : desc);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, DepartmentController controller, DepartmentModel department) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa phòng ban "${department.departmentName}" không?'),
        actions: [
          AppDialogActions.reactive(
            isSubmitting: controller.isSubmitting,
            onCancel: () => Get.back(),
            labels: AppDialogLabels.delete,
            disableCancelWhileSubmitting: true,
            onSubmit: () => controller.deleteDepartment(department.departmentId),
          ),
        ],
      ),
    );
  }
}
