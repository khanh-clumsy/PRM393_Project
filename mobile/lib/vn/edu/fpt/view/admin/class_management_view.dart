import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/class_controller.dart';
import '../../models/class_model.dart';

class ClassManagementView extends StatelessWidget {
  const ClassManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClassController());

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
                ElevatedButton(
                  onPressed: controller.fetchInitialData,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (controller.classes.isEmpty) {
          return const Center(child: Text('Chưa có dữ liệu lớp học.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.classes.length,
          itemBuilder: (context, index) {
            final cls = controller.classes[index];
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context, controller),
        backgroundColor: const Color(0xFFE65100),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFormDialog(BuildContext context, ClassController controller, {ClassModel? cls}) {
    final isEditing = cls != null;
    final nameController = TextEditingController(text: cls?.className ?? '');
    int? selectedYearId = cls?.academicYearId;
    int? selectedTeacherId = cls?.homeroomTeacherId;

    if (controller.academicYears.isNotEmpty && selectedYearId == null) {
      selectedYearId = controller.academicYears.first.academicYearId;
    }

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(isEditing ? 'Sửa Lớp Học' : 'Thêm Lớp Học', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEditing)
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Năm học', border: OutlineInputBorder()),
                    value: selectedYearId,
                    items: controller.academicYears.map((y) {
                      return DropdownMenuItem<int>(
                        value: y.academicYearId,
                        child: Text(y.yearName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedYearId = val;
                      });
                    },
                  ),
                if (!isEditing) const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên lớp (VD: 10A1)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(labelText: 'Giáo viên chủ nhiệm (Có thể để trống)', border: OutlineInputBorder()),
                  value: selectedTeacherId,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('--- Chọn GVCN ---', style: TextStyle(color: Colors.grey)),
                    ),
                    ...controller.teachers.map((t) {
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
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE65100), foregroundColor: Colors.white),
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  Get.snackbar('Lỗi', 'Vui lòng nhập tên lớp', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }
                
                if (isEditing) {
                  controller.updateClass(cls.classId, name, selectedTeacherId);
                } else {
                  if (selectedYearId == null) {
                    Get.snackbar('Lỗi', 'Vui lòng chọn năm học', backgroundColor: Colors.redAccent, colorText: Colors.white);
                    return;
                  }
                  controller.createClass(name, selectedYearId!, selectedTeacherId);
                }
              },
              child: Text(isEditing ? 'Lưu' : 'Thêm'),
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteConfirm(BuildContext context, ClassController controller, ClassModel cls) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa lớp "${cls.className}" không?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              controller.deleteClass(cls.classId);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
