import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/student_class_controller.dart';
import '../../models/student_class_model.dart';
import '../../models/class_model.dart';
import '../../models/academic_year_model.dart';

class StudentClassManagementView extends StatelessWidget {
  const StudentClassManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentClassController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Phân công Học sinh vào Lớp', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.academicYears.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)));
        }

        if (controller.errorMessage.value.isNotEmpty && controller.academicYears.isEmpty) {
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

        return Column(
          children: [
            // Filter Card
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
              child: Column(
                children: [
                  // Chọn Năm học
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: controller.selectedYearId.value,
                            hint: const Text('Chọn năm học', style: TextStyle(color: Colors.grey)),
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                            items: controller.academicYears.map((y) {
                              return DropdownMenuItem<int>(
                                value: y.academicYearId,
                                child: Text(y.yearName, style: const TextStyle(fontWeight: FontWeight.w500)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                controller.selectedYearId.value = val;
                                if (controller.filteredClasses.isNotEmpty) {
                                  controller.selectedClassId.value = controller.filteredClasses.first.classId;
                                  controller.fetchStudentClassesByClass(controller.selectedClassId.value!);
                                } else {
                                  controller.selectedClassId.value = null;
                                  controller.studentClasses.clear();
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, thickness: 1, color: Color(0xFFEEEEEE)),
                  // Chọn Lớp
                  Row(
                    children: [
                      const Icon(Icons.class_, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: controller.selectedClassId.value,
                            hint: const Text('Chọn Lớp học', style: TextStyle(color: Colors.grey)),
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                            items: controller.filteredClasses.map((c) {
                              return DropdownMenuItem<int>(
                                value: c.classId,
                                child: Text(c.className, style: const TextStyle(fontWeight: FontWeight.w500)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                controller.selectedClassId.value = val;
                                controller.fetchStudentClassesByClass(val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh sách học sinh (${controller.studentClasses.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // List
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)))
                  : controller.studentClasses.isEmpty
                      ? const Center(child: Text('Chưa có học sinh nào trong lớp này', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: controller.studentClasses.length,
                          itemBuilder: (context, index) {
                            final sc = controller.studentClasses[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade50,
                                  child: const Icon(Icons.person, color: Colors.blue),
                                ),
                                title: Text(sc.studentName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Mã HS: ${sc.studentCode ?? 'N/A'}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _showDeleteConfirm(context, controller, sc),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.selectedClassId.value == null) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => _showFormDialog(context, controller),
          backgroundColor: const Color(0xFFE65100),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Thêm Học sinh', style: TextStyle(color: Colors.white)),
        );
      }),
    );
  }

  void _showFormDialog(BuildContext context, StudentClassController controller) {
    int? selectedStudentId;

    // Lọc ra các học sinh chưa có trong lớp này (Hoặc có thể lọc chặt hơn: chưa có trong lớp nào trong năm nay)
    // Ở đây chỉ đơn giản lọc các học sinh chưa có trong danh sách hiển thị
    final availableStudents = controller.allStudents.where((s) {
      return !controller.studentClasses.any((sc) => sc.studentId == s.userId);
    }).toList();

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Thêm Học sinh', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownMenu<int>(
                  width: MediaQuery.of(context).size.width * 0.7, // Tự động chiếm 70% màn hình
                  enableFilter: true,
                  requestFocusOnTap: true,
                  label: const Text('Tìm hoặc chọn Học sinh'),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  dropdownMenuEntries: availableStudents.map((s) {
                    return DropdownMenuEntry<int>(
                      value: s.userId,
                      label: '${s.fullName} (${s.username})',
                    );
                  }).toList(),
                  onSelected: (val) {
                    setState(() {
                      selectedStudentId = val;
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (selectedStudentId == null) {
                  Get.snackbar('Lỗi', 'Vui lòng chọn học sinh', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }
                controller.addStudentToClass(selectedStudentId!, controller.selectedClassId.value!);
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteConfirm(BuildContext context, StudentClassController controller, StudentClassModel sc) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa học sinh ${sc.studentName} khỏi lớp này?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              controller.removeStudentFromClass(sc.studentClassId, controller.selectedClassId.value!);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
