import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/academic_year_controller.dart';
import '../../models/academic_year_model.dart';
import 'package:intl/intl.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFormDialog(BuildContext context, AcademicYearController controller, {AcademicYearModel? year}) {
    final isEditing = year != null;
    final nameController = TextEditingController(text: year?.yearName ?? '');

    bool isActive = year?.isActive ?? false;
    DateTime selectedStartDate = year != null ? DateTime.parse(year.startDate) : DateTime.now();
    DateTime selectedEndDate = year != null ? DateTime.parse(year.endDate) : DateTime.now().add(const Duration(days: 270));

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEditing ? 'Sửa Năm Học' : 'Thêm Năm Học', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên năm học (VD: 2023-2024)',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ngày bắt đầu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedStartDate)),
                  trailing: const Icon(Icons.calendar_month, color: Color(0xFFE65100)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedStartDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        selectedStartDate = date;
                      });
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ngày kết thúc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedEndDate)),
                  trailing: const Icon(Icons.calendar_month, color: Color(0xFFE65100)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedEndDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        selectedEndDate = date;
                      });
                    }
                  },
                ),
                const Divider(height: 1),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Trạng thái Hoạt động", style: TextStyle(fontSize: 14)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final name = nameController.text.trim();
                
                if (name.isEmpty) {
                  Get.snackbar('Lỗi', 'Vui lòng nhập Tên năm học', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }

                // Format validation: YYYY-YYYY
                final regex = RegExp(r'^\d{4}-\d{4}$');
                if (!regex.hasMatch(name)) {
                  Get.snackbar('Lỗi', 'Tên năm học phải có định dạng YYYY-YYYY (VD: 2024-2025)', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }

                final parts = name.split('-');
                final startYear = int.parse(parts[0]);
                final endYear = int.parse(parts[1]);

                if (endYear <= startYear) {
                  Get.snackbar('Lỗi', 'Năm kết thúc phải lớn hơn năm bắt đầu', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }

                if (selectedEndDate.isBefore(selectedStartDate)) {
                  Get.snackbar('Lỗi', 'Ngày kết thúc phải sau ngày bắt đầu', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }

                final startStr = DateFormat('yyyy-MM-dd').format(selectedStartDate);
                final endStr = DateFormat('yyyy-MM-dd').format(selectedEndDate);

                if (isEditing) {
                  controller.updateAcademicYear(year.academicYearId, name, startStr, endStr, isActive);
                } else {
                  controller.createAcademicYear(name, startStr, endStr, isActive);
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa năm học "${year.yearName}" không?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
