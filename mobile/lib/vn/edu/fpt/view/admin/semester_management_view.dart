import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/semester_controller.dart';
import '../../models/academic_year_model.dart';
import '../../models/semester_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog_actions.dart';

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
                AppButton.retry(onPressed: controller.fetchSemesters),
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
                if (controller.filteredSemesters.isEmpty) {
                  return const Center(child: Text('Chưa có học kỳ nào cho năm học này.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredSemesters.length,
                  itemBuilder: (context, index) {
                    final sem = controller.filteredSemesters[index];
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
      )
    ]);
    }),
      floatingActionButton: AppFab.add(
        onPressed: () => _showFormDialog(context, controller),
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
      selectedYearId = AcademicYearModel.preferredDefaultId(controller.academicYears);
    }

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEditing ? 'Sửa Học Kỳ' : 'Thêm Học Kỳ', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEditing)
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Năm học',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
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
                  decoration: InputDecoration(
                    labelText: 'Tên học kỳ (VD: Fall 2024)',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: startDateController,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      startDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Ngày bắt đầu (YYYY-MM-DD)',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: endDateController,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      endDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Ngày kết thúc (YYYY-MM-DD)',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
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
                final start = startDateController.text.trim();
                final end = endDateController.text.trim();
                
                if (name.isEmpty || start.isEmpty || end.isEmpty) {
                  Get.snackbar('Lỗi', 'Vui lòng nhập đủ thông tin', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }
                
                try {
                  final parsedStart = DateTime.parse(start);
                  final parsedEnd = DateTime.parse(end);
                  if (parsedStart.isAfter(parsedEnd)) {
                    Get.snackbar('Lỗi', 'Ngày bắt đầu không được lớn hơn ngày kết thúc', backgroundColor: Colors.redAccent, colorText: Colors.white);
                    return;
                  }
                } catch (e) {
                  Get.snackbar('Lỗi', 'Định dạng ngày không hợp lệ', backgroundColor: Colors.redAccent, colorText: Colors.white);
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
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteConfirm(BuildContext context, SemesterController controller, SemesterModel semester) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa học kỳ "${semester.semesterName}" không?'),
        actions: [
          AppDialogActions.reactive(
            isSubmitting: controller.isSubmitting,
            onCancel: () => Get.back(),
            labels: AppDialogLabels.delete,
            disableCancelWhileSubmitting: true,
            onSubmit: () => controller.deleteSemester(semester.semesterId),
          ),
        ],
      ),
    );
  }
}
