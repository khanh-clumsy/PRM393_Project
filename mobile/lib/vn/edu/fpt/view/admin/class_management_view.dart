import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/auth/role_context.dart';
import '../../controllers/class_controller.dart';
import '../../models/class_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog_actions.dart';

class ClassManagementView extends StatelessWidget {
  final ScopeMode scopeMode;
  const ClassManagementView({super.key, this.scopeMode = ScopeMode.admin});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClassController(scopeMode: scopeMode));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Quản lý Lớp học', style: TextStyle(fontWeight: FontWeight.bold)),
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
                AppButton.retry(onPressed: controller.fetchInitialData),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Dropdown chọn Năm học
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.school, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  const Text('Năm học:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: controller.selectedYearId.value,
                        hint: const Text('Chọn năm học'),
                        items: controller.academicYears.map((y) {
                          return DropdownMenuItem<int>(
                            value: y.academicYearId,
                            child: Text(y.yearName, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedYearId.value = val;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            
            Expanded(
              child: Builder(builder: (context) {
                if (controller.filteredClasses.isEmpty) {
                  return const Center(child: Text('Chưa có dữ liệu lớp học cho năm này.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredClasses.length,
                  itemBuilder: (context, index) {
                    final cls = controller.filteredClasses[index];
            final year = controller.academicYears.firstWhereOrNull((y) => y.academicYearId == cls.academicYearId);
            final teacher = controller.teachers.firstWhereOrNull((t) => t.userId == cls.homeroomTeacherId);
            
            return Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE0F2F1),
                  child: Icon(Icons.class_, color: Colors.teal),
                ),
                title: Text('${cls.className} ${year != null ? "(${year.yearName})" : ""}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(teacher != null ? 'GVCN: ${teacher.fullName}' : 'Chưa có GVCN'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _showFormDialog(context, controller, cls: cls),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _showDeleteConfirm(context, controller, cls),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      )
    ]);
    }),
      floatingActionButton: AppFab.add(
        onPressed: () => _showFormDialog(context, controller),
      ),
    );
  }

  void _showFormDialog(BuildContext context, ClassController controller, {ClassModel? cls}) {
    final isEditing = cls != null;
    final nameController = TextEditingController(text: cls?.className ?? '');
    final yearId = isEditing ? cls.academicYearId : controller.selectedYearId.value;
    int? selectedTeacherId = cls?.homeroomTeacherId;

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEditing ? 'Sửa Lớp Học' : 'Thêm Lớp Học', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên lớp (VD: 10A1)',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  decoration: InputDecoration(
                    labelText: 'Giáo viên chủ nhiệm (Có thể để trống)',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  value: selectedTeacherId,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('--- Chọn GVCN ---', style: TextStyle(color: Colors.grey)),
                    ),
                    ...controller.getAvailableTeachers(yearId ?? 0, cls?.classId).map((t) {
                      return DropdownMenuItem<int?>(
                        value: t.userId,
                        child: Text(t.fullName),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() {
                      selectedTeacherId = val;
                    });
                  },
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
                if (name.isEmpty) {
                  Get.snackbar('Lỗi', 'Vui lòng nhập tên lớp', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }

                if (isEditing) {
                  controller.updateClass(cls.classId, name, selectedTeacherId);
                } else {
                  if (yearId == null) {
                    Get.snackbar('Lỗi', 'Vui lòng chọn năm học ở danh sách phía trên', backgroundColor: Colors.redAccent, colorText: Colors.white);
                    return;
                  }
                  controller.createClass(name, yearId, selectedTeacherId);
                }
              },
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteConfirm(BuildContext context, ClassController controller, ClassModel cls) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa lớp "${cls.className}" không?'),
        actions: [
          AppDialogActions.reactive(
            isSubmitting: controller.isSubmitting,
            onCancel: () => Get.back(),
            labels: AppDialogLabels.delete,
            disableCancelWhileSubmitting: true,
            onSubmit: () => controller.deleteClass(cls.classId),
          ),
        ],
      ),
    );
  }
}
