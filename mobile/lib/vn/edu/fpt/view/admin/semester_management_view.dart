import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/semester_controller.dart';
import '../../models/semester_model.dart';

class SemesterManagementView extends StatelessWidget {
  const SemesterManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SemesterController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Quản lý Học kỳ', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  onPressed: controller.fetchSemesters,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (controller.semesters.isEmpty) {
          return const Center(child: Text('Chưa có dữ liệu học kỳ.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.semesters.length,
          itemBuilder: (context, index) {
            final sem = controller.semesters[index];
            final year = controller.academicYears.firstWhereOrNull((y) => y.academicYearId == sem.academicYearId);
            
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
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.date_range, color: Colors.blue),
                ),
                title: Text('${sem.semesterName} ${year != null ? "(${year.yearName})" : ""}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${sem.startDate} - ${sem.endDate}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _showFormDialog(context, controller, semester: sem),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _showDeleteConfirm(context, controller, sem),
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

  void _showFormDialog(BuildContext context, SemesterController controller, {SemesterModel? semester}) {
    final isEditing = semester != null;
    final nameController = TextEditingController(text: semester?.semesterName ?? '');
    final startDateController = TextEditingController(text: semester?.startDate ?? '');
    final endDateController = TextEditingController(text: semester?.endDate ?? '');
    int? selectedYearId = semester?.academicYearId;

    if (controller.academicYears.isNotEmpty && selectedYearId == null) {
      selectedYearId = controller.academicYears.first.academicYearId;
    }

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(isEditing ? 'Sửa Học Kỳ' : 'Thêm Học Kỳ', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  decoration: const InputDecoration(labelText: 'Tên học kỳ (VD: Fall 2024)', border: OutlineInputBorder()),
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
                  controller.updateSemester(semester.semesterId, name, start, end);
                } else {
                  if (selectedYearId == null) {
                    Get.snackbar('Lỗi', 'Vui lòng chọn năm học', backgroundColor: Colors.redAccent, colorText: Colors.white);
                    return;
                  }
                  controller.createSemester(selectedYearId!, name, start, end);
                }
              },
              child: Text(isEditing ? 'Lưu' : 'Thêm'),
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteConfirm(BuildContext context, SemesterController controller, SemesterModel semester) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa học kỳ "${semester.semesterName}" không?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              controller.deleteSemester(semester.semesterId);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
