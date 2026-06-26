import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/academic_year_controller.dart';
import '../../models/academic_year_model.dart';

class AcademicYearManagementView extends StatelessWidget {
  const AcademicYearManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AcademicYearController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Quản lý Năm học', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  onPressed: controller.fetchAcademicYears,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (controller.academicYears.isEmpty) {
          return const Center(child: Text('Chưa có dữ liệu năm học.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.academicYears.length,
          itemBuilder: (context, index) {
            final year = controller.academicYears[index];
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
                  backgroundColor: year.isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  child: Icon(
                    year.isActive ? Icons.check_circle : Icons.cancel,
                    color: year.isActive ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(year.yearName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${year.startDate} - ${year.endDate}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _showFormDialog(context, controller, year: year),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _showDeleteConfirm(context, controller, year),
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

  void _showFormDialog(BuildContext context, AcademicYearController controller, {AcademicYearModel? year}) {
    final isEditing = year != null;
    final nameController = TextEditingController(text: year?.yearName ?? '');
    final startDateController = TextEditingController(text: year?.startDate ?? '');
    final endDateController = TextEditingController(text: year?.endDate ?? '');
    bool isActive = year?.isActive ?? false;

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(isEditing ? 'Sửa Năm Học' : 'Thêm Năm Học', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên năm học (VD: 2023-2024)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: startDateController,
                  decoration: const InputDecoration(labelText: 'Ngày bắt đầu (YYYY-MM-DD)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: endDateController,
                  decoration: const InputDecoration(labelText: 'Ngày kết thúc (YYYY-MM-DD)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text("Trạng thái Hoạt động"),
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
                final name = nameController.text.trim();
                final start = startDateController.text.trim();
                final end = endDateController.text.trim();
                if (name.isEmpty || start.isEmpty || end.isEmpty) {
                  Get.snackbar('Lỗi', 'Vui lòng nhập đủ thông tin', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }
                if (isEditing) {
                  controller.updateAcademicYear(year.academicYearId, name, start, end, isActive);
                } else {
                  controller.createAcademicYear(name, start, end, isActive);
                }
              },
              child: Text(isEditing ? 'Lưu' : 'Thêm'),
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteConfirm(BuildContext context, AcademicYearController controller, AcademicYearModel year) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa năm học "${year.yearName}" không?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              controller.deleteAcademicYear(year.academicYearId);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
